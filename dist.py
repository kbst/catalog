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


SRCDIR = 'src'
DISTDIR = '_dist'

# Clean DISTDIR
if isdir(DISTDIR):
    rmtree(DISTDIR)
mkdir(DISTDIR)

# Get name and version
release_version = environ.get('TAG_NAME', None)
available_names = [n for n in listdir(SRCDIR) if not n.startswith('_')]

if release_version:
    # We're releasing a specific catalog entry
    # tag must have name-version format

    for name in available_names:
        prefix = f'{name}-'
        if release_version.startswith(prefix):
            version = release_version.lstrip(prefix)
            break

    if not isdir(f'{SRCDIR}/{name}'):
        exit(f"[ERROR] `{name}` is not in available names {available_names}")

    create_archive(name, version)
else:
    # We're not making a release, build all entries
    branch = environ.get('BRANCH_NAME', None)
    if not branch:
        exit(f"[ERROR] `BRANCH_NAME` env var not set")

    hash = environ.get('SHORT_SHA', None)
    if not hash:
        exit(f"[ERROR] `SHORT_SHA` env var not set")

    version = f'{branch}-{hash}'

    for name in available_names:
        create_archive(name, version)
