#!/usr/bin/env python3

from os import listdir
from os.path import isdir, isfile, join
from subprocess import CalledProcessError, run
from tempfile import TemporaryDirectory
from nose import with_setup
from shutil import unpack_archive

DISTDIR = "/_dist"
TESTDIR = TemporaryDirectory()


def run_cmd(build_path):
    try:
        build = run(
            ['kustomize', 'build', build_path],
            check=True,
            capture_output=True,
            text=True)
    except CalledProcessError as failed_build:
        print(failed_build.stdout)
        print(failed_build.stderr)

    assert build.returncode == 0


def setup():
    # unpack zip archives in DISTDIR
    for name in listdir(DISTDIR):
        path = join(DISTDIR, name)
        if not isfile(path) and not path.endswith(".zip"):
            continue

        unpack_archive(path, TESTDIR.name, "zip")


def teardown():
    TESTDIR.cleanup()


@with_setup(setup, teardown)
def test_build():
    for entry in listdir(TESTDIR.name):
        entry_path = join(TESTDIR.name, entry)
        if not isdir(entry_path):
            continue

        for overlay in listdir(entry_path):
            build_path = join(entry_path, overlay)
            if not isdir(build_path):
                continue

            yield run_cmd, build_path
