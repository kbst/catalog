#!/usr/bin/env python3

from os import environ, listdir, mkdir
from os.path import isdir
from shutil import rmtree, copytree
from sys import exit

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
copytree(f'{SRCDIR}/{name}', f'{DISTDIR}/{name}/{version}')
