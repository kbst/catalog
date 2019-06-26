#!/usr/bin/env python3

from os import listdir
from os.path import isdir, join
from subprocess import CalledProcessError, run

DISTDIR = '_dist'

failed_builds = []
for entry_dir in listdir(DISTDIR):
    entry_path = join(DISTDIR, entry_dir)
    if not isdir(entry_path):
        continue

    for build_dir in listdir(entry_path):
        build_path = join(entry_path, build_dir)
        if not isdir(build_path):
            continue

        try:
            build = run(
                ['kustomize', 'build', build_path],
                check=True,
                capture_output=True,
                text=True)
        except CalledProcessError as failed_build:
            print(f"\n\n[ERROR] `{entry_dir}` `{build_dir}` build failed\n",
                  f"  {failed_build}\n",
                  f"  {failed_build.stderr}")
            failed_builds.append(f"{entry_dir} {build_dir}")
        else:
            print(f"[INFO] `{entry_dir}` `{build_dir}` build succesful")

if len(failed_builds) != 0:
    number = len(failed_builds)
    names = ', '.join(failed_builds)
    exit(f"\n\n[ERROR] {number} failing builds: {names}")
