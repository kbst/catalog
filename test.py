#!/usr/bin/env python3

from os import environ, listdir
from os.path import isdir
from subprocess import call
from sys import exit

DISTDIR = '_dist'

# Get name and version
name_version = environ.get('TAG_NAME', None)
if not name_version:
    name_version = environ.get('BRANCH_NAME', None)

try:
    name, version = name_version.split('-', 1)
except ValueError:
    exit(f"[ERROR] `{name_version}` not in `name-version` format")

for dirname in listdir(f'{DISTDIR}'):
    build_path = f'{DISTDIR}/{dirname}'
    if not isdir(build_path):
        continue

    call(['kustomize', 'build', build_path])
