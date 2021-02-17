#!/usr/bin/env python3

import time
import logging
from os import listdir
from os.path import isdir, isfile, join, abspath
from subprocess import Popen, PIPE
from tempfile import TemporaryDirectory
from nose import with_setup
from shutil import unpack_archive
from kubernetes import client, config
from jinja2 import Environment, FileSystemLoader

DISTDIR = "/_dist"
TESTDIR = TemporaryDirectory()
TIMEOUT = 300  # 5 minutes in seconds


def run_cmd(name, path, cmd, timeout):
    start = time.time()
    p = Popen(cmd, cwd=path, stdout=PIPE, stderr=PIPE)
    while True:
        # we give up
        if (time.time() - start) >= timeout:
            break

        exit_code = p.poll()
        if exit_code is not None:
            break

    if exit_code != 0:
        o = p.stdout.read()
        if o:
            logging.error(o.strip().decode("UTF-8"))

        e = p.stderr.read()
        if e:
            logging.error(e.strip().decode("UTF-8"))

    assert exit_code == 0


def wait_retries(name, timeout):
    config.load_kube_config()

    v1 = client.CoreV1Api()

    count = 0
    start = time.time()
    failed_pods = []

    while True:
        # we give up
        if (time.time() - start) >= timeout:
            break

        failed_pods = []

        ret = v1.list_pod_for_all_namespaces(watch=False)

        for p in ret.items:
            metann = f"{p.metadata.namespace}/{p.metadata.name}"

            # continue if there are no conditions yet
            if not p.status.conditions:
                continue

            is_ready = False
            for c in p.status.conditions:
                if c.type != "Ready":
                    continue

                if c.status == "True" or (c.status == "False" and c.reason == "PodCompleted"):
                    is_ready = True

            if not is_ready:
                failed_pods.append(metann)

        # we're done here
        if len(failed_pods) == 0:
            break

        # we're not done
        # sleep a little, then try again
        count += 1
        time.sleep(min(count * 2, 30))

    # output debug info
    if len(failed_pods) > 0:
        ret = v1.list_pod_for_all_namespaces(watch=False)
        for p in ret.items:
            metann = f"{p.metadata.namespace}/{p.metadata.name}"
            podstatus = f"{p.status.phase:<11}  {metann}"
            logging.error(podstatus)

        logging.error(f"timed out waiting for: {failed_pods}")

    assert len(failed_pods) == 0


def run_steps(name, path):
    steps = {
        "init": {"type": "run_cmd",
                 "path": path,
                 "cmd": ["terraform", "init"]},
        "apply": {"type": "run_cmd",
                          "path": path,
                          "cmd": ["terraform",
                                  "apply",
                                  "--auto-approve"]},
        "wait": {"type": "wait_retries"},
        "destroy": {"type": "run_cmd",
                            "path": path,
                            "cmd": ["terraform",
                                    "destroy",
                                    "--auto-approve"]}
    }

    for step in steps.values():
        if step["type"] == "run_cmd":
            run_cmd(name, step["path"], step["cmd"], TIMEOUT)
        if step["type"] == "wait_retries":
            wait_retries(name, TIMEOUT)


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
def test_variants():
    root_module = TESTDIR.name
    for entry in listdir(TESTDIR.name):
        entry_module = join(TESTDIR.name, entry)
        if not isdir(entry_module):
            continue

        for variant in listdir(entry_module):
            variant_path = join(entry_module, variant)
            if not isdir(variant_path):
                continue

            # write main.tf into root_module
            jinja = Environment(loader=FileSystemLoader("."))
            template = jinja.get_template('main.tf.tpl')
            data = template.render(
                {'entry_module': entry_module, 'variant': variant})

            with open(f'{root_module}/main.tf', 'w') as f:
                f.write(data)
                # always include newline at end of file
                f.write('\n')

            # yield instructs nose to treat each variant as a separate test
            yield run_steps, f"{entry}/{variant}", root_module
