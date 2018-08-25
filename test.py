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

if not isdir(f'{DISTDIR}/{name}'):
    available_names = [n for n in listdir(DISTDIR) if not n.startswith('_')]
    exit(f"[ERROR] name `{name}` is not in available names {available_names}")

for dirname in listdir(f'{DISTDIR}/{name}/{version}'):
    call(['kustomize', 'build', f'{DISTDIR}/{name}/{version}/{dirname}'])
