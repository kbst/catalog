#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir
from shutil import rmtree, copytree
from sys import exit
import lzma
import tarfile

SRCDIR = 'src'
DISTDIR = '_dist'
DESIRED_FORMAT = 'name-version e.g. memcached-v0.0.1'

# Get name and version
name_version = environ.get('TAG_NAME', None)
if not name_version:
    name_version = environ.get('BRANCH_NAME', None)

try:
    name, version = name_version.split('-', 1)
except ValueError:
    exit(f"[ERROR] `{name_version}` not in `name-version` format")

if not isdir(f'{SRCDIR}/{name}'):
    available_names = [n for n in listdir(SRCDIR) if not n.startswith('_')]
    exit(f"[ERROR] name `{name}` is not in available names {available_names}")

# Clean DISTDIR
if isdir(DISTDIR):
    rmtree(DISTDIR)
mkdir(DISTDIR)

# Copy {name} and _common
variants = [n for n in listdir(f'{SRCDIR}/{name}') if not n.startswith('_')]

for variant in variants:
    variant_src = f'{SRCDIR}/{name}/{variant}'
    variant_dist = f'{DISTDIR}/{name}-{version}-{variant}'
    archive_name = f'{variant_dist}.txz'

    copytree(variant_src, variant_dist)

    with lzma.open(archive_name, mode='w') as xz_file:
        with tarfile.open(mode='w', fileobj=xz_file) as txz_file:
            txz_file.add(f'{variant_dist}/', arcname='')
