#!/usr/bin/env python3

from os import listdir
from os.path import isdir, isfile, join, abspath
from subprocess import Popen, PIPE
from tempfile import TemporaryDirectory
from nose import with_setup
from shutil import unpack_archive

DISTDIR = "/_dist"
TESTDIR = TemporaryDirectory()


def run_cmd(name, cmd):
    p = Popen(cmd, stdout=PIPE, stderr=PIPE)
    while True:
        exit_code = p.poll()
        if exit_code is not None:
            break

    if exit_code != 0:
        o = p.stdout.read()
        if o:
            print(o.strip().decode("UTF-8"))

        e = p.stderr.read()
        if e:
            print(e.strip().decode("UTF-8"))

    assert exit_code == 0


def setup():
    # unpack zip archives in DISTDIR
    for name in listdir(DISTDIR):
        path = join(DISTDIR, name)
        if not isfile(path) and not path.endswith(".zip"):
            continue

        unpack_archive(path, TESTDIR.name, "zip")

    run_cmd("init", ["terraform", "init"])


def teardown():
    TESTDIR.cleanup()


@with_setup(setup, teardown)
def test_cmd():
    for entry in listdir(TESTDIR.name):
        entry_path = join(TESTDIR.name, entry)
        if not isdir(entry_path):
            continue

        for overlay in listdir(entry_path):
            overlay_path = join(entry_path, overlay)
            if not isdir(overlay_path):
                continue

            tfvar_arg = f"--var=path={overlay_path}"

            steps = {
                "apply": ["terraform",
                          "apply",
                          "--auto-approve",
                          "--parallelism=30",
                          tfvar_arg],
                "wait": ["kubectl",
                         "wait",
                         "pod",
                         "--for=condition=Ready",
                         "--timeout=300s",
                         "--all",
                         "--all-namespaces"],
                "destroy": ["terraform",
                            "destroy",
                            "--auto-approve",
                            tfvar_arg]
            }

            for step in steps:
                yield run_cmd, f"{entry}/{overlay}", steps[step]
