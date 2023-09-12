#!/usr/bin/env python3

from json import dumps
from os import environ, listdir, mkdir
from os.path import isdir, isfile, join
from shutil import copytree, ignore_patterns, make_archive, rmtree, unpack_archive
from sys import exit
from tempfile import TemporaryDirectory


def create_archive(name, version):
    src = join(SRCDIR, name)

    module_dist = join(DISTDIR, f'module-{name}')
    module = join(DISTDIR, f'module-{name}-{version}')

    copytree(src, module_dist, ignore=ignore_patterns('_*'))

    make_archive(module, 'zip', module_dist)


def get_build_targets(ref):
    """ Returns build targets

        Returns a list of name and version tuples.

        If the ref name is prefixed with one of the available names,
        it returns a list of length one.

        If the ref is a branch, a short commit hash will be appended
        to the version.

        Refuse to build multiple artifacts for tags. Releases need
        to be for a single entry.
    """
    name = None
    version = None

    if ref.startswith('refs/tags/'):
        ref_name = ref.replace('refs/tags/', '')
        is_tag = True

    if ref.startswith('refs/heads/'):
        ref_name = ref.replace('refs/heads/', '')
        is_tag = False

    if ref.startswith('refs/heads/release-'):
        ref_name = ref.replace('refs/heads/release-', '')
        is_tag = False

    available_names = [n for n in listdir(SRCDIR) if not n.startswith('_')]

    targets = []
    for name in available_names:
        prefix = f'{name}-'

        # Version based on tag (e.g. refs/tags/nginx-v0.43.1-kbst.0)
        version = ref_name.replace(prefix, '')

        # Version based on branch (e.g. refs/heads/nginx-mychange)
        if not is_tag:
            hash = environ.get('GITHUB_SHA', None)
            if not hash:
                exit(f"[ERROR] `GITHUB_SHA` env var not set")
            version = hash

        if ref_name.startswith(prefix):
            # We're building a specific target
            return [(name, version)]
        else:
            # We build all entries
            targets.append((name, version))

    if ref.startswith('refs/tags/') and len(targets) != 1:
        exit(f"[ERROR] Invalid `GITHUB_REF` '{ref}'. " +
             f"Tags must be prefixed with one of {available_names}")

    if ref.startswith('refs/heads/all-'):
        # Building all targets takes very long, we only do so
        # when the branch name starts with `all-`
        return targets

    # if neither a specifc nor all entries were requested
    # we default to the test entry
    return [("test", hash)]

if __name__ == "__main__":
    SRCDIR = 'src'
    DISTDIR = '_dist'
    OUTPUTSFILE = environ.get('GITHUB_OUTPUT')

    #
    #
    # Clean DISTDIR
    if isdir(DISTDIR):
        rmtree(DISTDIR)
    mkdir(DISTDIR)

    #
    #
    # Build artifacts
    ref = environ.get('GITHUB_REF', None)
    if not ref:
        exit(f"[ERROR] `GITHUB_REF` env var not set")

    if not ref.startswith('refs/tags/') and not ref.startswith('refs/heads/'):
        exit(f"[ERROR] unexpected `GITHUB_REF`: {ref}")

    build_targets = get_build_targets(ref)

    for name, version in build_targets:
        create_archive(name, version)

    #
    #
    # Generate all entries output for publish-gh job
    all_targets = get_build_targets("refs/heads/all-targets")
    
    names = []
    for name, _ in all_targets:
        names.append(f'"{name}"')

    tf_var_names_output = f'TF_VAR_names=[{",".join(names)}]'

    #
    #
    # Generate matrix output for test job
    matrix_output_data = {
        "include": []
    }

    for name in listdir(DISTDIR):
        if not isfile(name) and (not name.startswith('module-') or not name.endswith('.zip')):
            continue

        with TemporaryDirectory() as root:
            mut = join(root, "mut")
            archive = join(DISTDIR, name)
            unpack_archive(archive, mut, "zip")
            for variant in listdir(mut):
                variant_path = join(mut, variant)
                if not isdir(variant_path):
                    continue
                
                matrix_output_data["include"].append({
                    "variant": variant,
                    "name": name
                })

    matrix_output = f'matrix={dumps(matrix_output_data)}'


    #
    #
    # Write or print outputs
    if OUTPUTSFILE:
        with open(OUTPUTSFILE, 'a') as f:
            f.write(f'{tf_var_names_output}\n')
            f.write(f'{matrix_output}\n')
        exit(0)

    print(tf_var_names_output)
    print(matrix_output)
    exit(0)
