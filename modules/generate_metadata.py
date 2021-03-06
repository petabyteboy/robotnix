#!/usr/bin/env python3

# From https://github.com/GrapheneOS/script/blob/pie/generate_metadata.py
# Modified to just use stdout. Write to ${device}-{stable,beta}

import sys
from argparse import ArgumentParser
from zipfile import ZipFile

parser = ArgumentParser(description="Generate update server metadata")
parser.add_argument("zip")

with ZipFile(parser.parse_args().zip) as f:
    with f.open("META-INF/com/android/metadata") as metadata:
        data = dict(line[:-1].decode().split("=") for line in metadata)
        build_id = data["post-build"].split("/")[3]
        incremental = data["post-build"].split("/")[4].split(":")[0]
        print(incremental, data["post-timestamp"], build_id, file=sys.stdout)

