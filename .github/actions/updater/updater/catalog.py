import re
import logging
import subprocess
from os import listdir, path

from git.exc import GitCommandError

from repo import clone_or_reset_repo

import settings

import yaml


class Catalog():
    def __init__(self):
        self.clone_or_reset()

    def clone_or_reset(self):
        self.repo = clone_or_reset_repo(settings.CATALOG_NAME,
                                        settings.CATALOG_URL,
                                        settings.CATALOG_REF)

        # set git identity for commits
        self.repo.git.config('user.name', settings.GIT_USER_NAME)
        self.repo.git.config('user.email', settings.GIT_USER_EMAIL)

    def get_src_dir(self):
        return path.join(self.repo.working_tree_dir, 'src')

    def get_entries(self):
        src_dir = self.get_src_dir()
        return sorted([n for n in listdir(src_dir) if not n.startswith('_')])

    def get_variants(self, entry):
        entry_dir = path.join(self.get_src_dir(), entry.name)
        variants = []
        for v in listdir(entry_dir):
            if path.isdir(v) and not v.startswith('_'):
                variants.append(v)
        return sorted(variants)

    def run_script(self, entry, target_path):
        run_script_path = path.join(target_path, '_updater', 'run.sh')

        cmd = ['/bin/sh',
               run_script_path,
               entry.repo.working_tree_dir,
               target_path,
               str(entry.tag)]

        try:
            subprocess.run(cmd,
                           check=True,
                           capture_output=True,
                           text=True)
        except subprocess.CalledProcessError as e:
            logging.error(f'updating {entry.name} failed, '
                          f'stderr: "{e.stderr}"')
            self.clone_or_reset()
            self.repo.git.branch('-d', self.branch_name)
            return False
        else:
            logging.info(f'updated {entry.name} successfully')
        return True

    def update_version_annotation(self, kpath, version):
        kustomization_path = path.join(kpath, 'kustomization.yaml')
        with open(kustomization_path, 'r+') as stream:
            try:
                kf = yaml.safe_load(stream)
            except yaml.YAMLError as e:
                logging.exception(e)
            if 'commonAnnotations' not in kf:
                kf['commonAnnotations'] = {}
            kf['commonAnnotations']['app.kubernetes.io/version'] = version
            yaml.dump(kf,
                      default_flow_style=False,
                      indent=2,
                      sort_keys=False)
            stream.seek(0)
            stream.write(yaml.dump(kf,
                                   default_flow_style=False,
                                   indent=2,
                                   sort_keys=False))
            stream.truncate()

    def update_entry(self, entry):
        current_version = str(entry.tag)

        # skip tags not matching regex
        if 'filter_tags' in entry.metadata:
            regex = entry.metadata['filter_tags']
            match = re.match(regex, current_version)
            if match:
                current_version = match.group(1)
            else:
                # if the regex does not match, we skip this tag
                return

        # in case upstream prefixes v, remove it
        # because we always prefix v for our tags
        current_version = current_version.lstrip('v')
        release_version = f'v{current_version}'
        release_tag = f'{entry.name}-{release_version}-kbst.0'

        if release_tag in entry.releases:
            # skip the upstream tag, if we already have a kbst.0 release for it
            logging.debug(f'skipping {release_tag}, already exists')
            return

        # checkout tag to build in source repo
        entry.repo.git.checkout('-f', entry.tag)

        self.branch_name = f'release-{release_tag}'
        self.repo.git.checkout(settings.CATALOG_REF)
        self.repo.git.clean('-xdf')
        self.repo.git.checkout('-B', self.branch_name)

        target_path = path.join(self.get_src_dir(), entry.name)

        # run entry updater script
        script_success = self.run_script(entry, target_path)
        if not script_success:
            return

        # update or set version annotation on all variants
        for variant in self.get_variants(entry):
            variant_path = path.join(target_path, variant)
            self.update_version_annotation(variant_path, release_version)

        self.repo.git.add('.')
        self.repo.git.commit('-m', f'Release {release_tag}')
        try:
            self.repo.git.push('origin', self.branch_name)
        except GitCommandError as e:
            logging.error(f'push of {self.branch_name} branch rejected')
            logging.error(f'git error: {e}')
            return
        else:
            logging.info(f'push of {self.branch_name} branch successful')
