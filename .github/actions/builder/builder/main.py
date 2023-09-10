#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir, join
from shutil import copytree, ignore_patterns, make_archive, rmtree
from sys import exit


def create_archive(name, version):
    src = join(SRCDIR, name)

    module_dist = join(DISTDIR, f'module-{name}')
    module = join(DISTDIR, f'module-{name}-{version}')

    copytree(src, module_dist, ignore=ignore_patterns('_*'))

    make_archive(module, 'zip', module_dist)
    print(f"[INFO] created `{module}.zip`")


def get_build_targets(ref):
    """ Returns build targets

        Returns a list of name and version tuples.

        If the ref name is prefixed with one of the available names,
        it returns a list of length one.

        If the ref is a branch, a short commit hash will be appended
        to the version.

        Refuse to build multiple artifacts for tags. Releases need
        to be for a single entry.
    """
    name = None
    version = None

    if ref.startswith('refs/tags/'):
        ref_name = ref.replace('refs/tags/', '')
        is_tag = True
    elif ref.startswith('refs/heads/'):
        ref_name = ref.replace('refs/heads/', '')
        is_tag = False

    available_names = [n for n in listdir(SRCDIR) if not n.startswith('_')]

    targets = []
    for name in available_names:
        prefix = f'{name}-'

        # Version based on tag (e.g. refs/tags/nginx-v0.43.1-kbst.0)
        version = ref_name.replace(prefix, '')

        # Version based on branch (e.g. refs/heads/nginx-mychange)
        if not is_tag:
            hash = environ.get('GITHUB_SHA', None)
            if not hash:
                exit(f"[ERROR] `GITHUB_SHA` env var not set")
            version = hash

        if ref_name.startswith(prefix):
            # We're building a specific target
            return [(name, version)]
        else:
            # We build all entries
            targets.append((name, version))

    if ref.startswith('refs/tags/') and len(targets) != 1:
        exit(f"[ERROR] Invalid `GITHUB_REF` '{ref}'. " +
             f"Tags must be prefixed with one of {available_names}")

    if ref.startswith('refs/heads/all-'):
        # Building all targets takes very long, we only do so
        # when the branch name starts with `all-`
        return targets

    # if neither a specifc nor all entries were requested
    # we default to the test entry
    return [("test", hash)]


if __name__ == "__main__":
    SRCDIR = 'src'
    DISTDIR = '_dist'

    # Clean DISTDIR
    if isdir(DISTDIR):
        rmtree(DISTDIR)
    mkdir(DISTDIR)

    # Get name and version
    ref = environ.get('GITHUB_REF', None)
    if not ref:
        exit(f"[ERROR] `GITHUB_REF` env var not set")

    if not ref.startswith('refs/tags/') and not ref.startswith('refs/heads/'):
        exit(f"[ERROR] unexpected `GITHUB_REF`: {ref}")

    build_targets = get_build_targets(ref)

    for name, version in build_targets:
        create_archive(name, version)
