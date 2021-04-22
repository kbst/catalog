import logging
from datetime import datetime
from os import path

from git.objects.commit import Commit
from git.objects.tag import TagObject

from repo import clone_or_reset_repo

import yaml


class Entry():
    def __init__(self, catalog, name):
        self.catalog = catalog
        self.name = name
        self.metadata = None
        self.repo = None
        self.tag = None
        self.date = None

    def get_tag_date(self, tag):
        # lightweight tags don't have tagged_date
        # use the commit object's date then
        date = 0
        logging.debug(f'getting date of {tag} for {self.name}')
        object = tag.object
        if type(object) is Commit:
            date = object.committed_date
        elif type(object) is TagObject:
            date = object.tagged_date
        else:
            logging.warning(f'skipping {tag} for {self.name} '
                            f'due to unknow object type {type(object)}')
        return date

    def get_metadata(self):
        src_dir = self.catalog.get_src_dir()
        metadata_path = path.join(src_dir,
                                  self.name,
                                  '_updater',
                                  'metadata.yaml')
        try:
            with open(metadata_path) as stream:
                try:
                    metadata = yaml.safe_load(stream)
                except yaml.YAMLError as e:
                    logging.exception(e)
        except FileNotFoundError:
            logging.warning(f'skipping {self.name} '
                            'due to missing metadata')
        else:
            return metadata
        return None

    def check_releases(self):
        logging.debug(f'start updating {self.name}')

        self.metadata = self.get_metadata()
        if not self.metadata:
            return

        self.repo = clone_or_reset_repo(
            self.name,
            self.metadata.get('url'),
            self.metadata.get('ref', 'master'))
        entry_tags = sorted(self.repo.tags,
                            key=lambda x: self.get_tag_date(x))
        if not entry_tags:
            return

        catalog_tags = self.catalog.repo.tags
        self.releases = list(filter(
            lambda x: str(x).startswith(self.name),
            catalog_tags))

        latest_release = None
        self.latest_release_date = 0
        if self.releases:
            latest_release = sorted(self.releases,
                                    key=lambda x: self.get_tag_date(x))[-1]
            self.latest_release_date = self.get_tag_date(latest_release)

        for tag in entry_tags:
            if self.get_tag_date(tag) < self.latest_release_date:
                # skip tags older than the last release in the catalog
                dt = datetime.utcfromtimestamp(self.latest_release_date)
                log_date = dt.strftime('%Y-%m-%d %H:%M:%S')
                logging.debug(f'skipping {self.name} {tag}, '
                              f'older than {log_date}')
                continue

            self.tag = tag
            self.date = self.get_tag_date(self.tag)

            self.catalog.update_entry(self)

        self.repo.close()
        logging.debug(f'finished updating {self.name}')
