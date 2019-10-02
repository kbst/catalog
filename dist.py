#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir, join
from shutil import copytree, ignore_patterns, make_archive, rmtree
from sys import exit


def create_archive(name, version):
    archive_src = join(SRCDIR, name)
    archive_dist = join(DISTDIR, name)
    archive = join(DISTDIR, f'{name}-{version}')

    copytree(archive_src, archive_dist, ignore=ignore_patterns('_*'))

    make_archive(archive, 'zip', DISTDIR, name)
    print(f"[INFO] created `{archive}.zip`")


SRCDIR = 'src'
DISTDIR = '_dist'

# Clean DISTDIR
if isdir(DISTDIR):
    rmtree(DISTDIR)
mkdir(DISTDIR)

# Get name and version
ref_name = environ.get('GIT_REF', None)
if not ref_name:
    exit(f"[ERROR] `GIT_REF` env var not set")

available_names = [n for n in listdir(SRCDIR) if not n.startswith('_')]

if ref_name.startswith('refs/tags/'):
    # We're releasing a specific catalog entry
    # tag must have name-version format

    release_version = ref_name.lstrip('refs/tags/')

    for name in available_names:
        prefix = f'{name}-'
        if release_version.startswith(prefix):
            version = release_version.lstrip(prefix)
            break

    if not isdir(f'{SRCDIR}/{name}'):
        exit(f"[ERROR] `{name}` is not in catalog: {available_names}")

    create_archive(name, version)
elif ref_name.startswith('refs/heads/'):
    # We're not making a release, build all entries

    branch = ref_name.lstrip('refs/heads/')

    hash = environ.get('GIT_SHA', None)[0:7]
    if not hash:
        exit(f"[ERROR] `GIT_SHA` env var not set")

    version = f'{branch}-{hash}'

    for name in available_names:
        create_archive(name, version)
else:
    exit(f"[ERROR] unexpected `REF_NAME`: {ref_name}")
