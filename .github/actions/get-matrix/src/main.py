#!/usr/bin/env python3

from json import dumps
from os import environ, listdir
from os.path import isdir, isfile, join
from shutil import unpack_archive
from sys import exit
from tempfile import TemporaryDirectory

DISTDIR = "_dist"


if __name__ == '__main__':
    output = {
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
                
                output["include"].append({
                    "variant": variant,
                    "name": name
                })

    outputsFile = environ.get('GITHUB_OUTPUT')
    outputData = dumps(output)

    if outputsFile:
        with open(outputsFile, 'w') as f:
            f.write(f'matrix={outputData}')
        exit(0)

    print(outputData)
    exit(0)
