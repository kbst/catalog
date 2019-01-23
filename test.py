#!/usr/bin/env python3

from os import listdir
from os.path import isdir
from subprocess import CalledProcessError, run

DISTDIR = '_dist'

failed_builds = []

for dirname in listdir(f'{DISTDIR}'):
    build_path = f'{DISTDIR}/{dirname}'
    if not isdir(build_path):
        continue

    try:
        build = run(
            ['kustomize', 'build', build_path],
            check=True,
            capture_output=True,
            text=True)
    except CalledProcessError as failed_build:
        print(f"\n\n[ERROR] `{dirname}` build failed\n",
              f"  {failed_build}\n",
              f"  {failed_build.stderr}")
        failed_builds.append(dirname)
    else:
        print(f"[INFO] `{dirname}` build succesful")

if len(failed_builds) != 0:
    number = len(failed_builds)
    names = ', '.join(failed_builds)
    exit(f"\n\n[ERROR] {number} failing builds: {names}")
