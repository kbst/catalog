#!/usr/bin/env python3

from os import mkdir, listdir
from os.path import isdir
from shutil import rmtree, copytree
from subprocess import call
from sys import argv, exit

DISTDIR = '_dist'

if len(argv) != 2:
    exit("Usage: test.py GIT_TAG")

# Get name and version
name, version = argv[1].split('-', 1)

if not isdir(name):
    exit("GIT_TAG arg must be in format name-version e.g. memcached-v0.0.1")

for dirname in listdir(f'{DISTDIR}/{name}/{version}'):
    if not dirname.startswith('_'):
        call(['kustomize', 'build', f'{DISTDIR}/{name}/{version}/{dirname}'])
