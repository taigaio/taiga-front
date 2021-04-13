#!/usr/bin/env python

import os, sys
from pathlib import Path

LICENSE = """###
# File: {file_name}
###

{data}"""

CONTAIN_TEXT = "You should have received a copy of the GNU Affero General Public License"


BASE_DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

DIRS = [
    os.path.join(BASE_DIR, "app/coffee"),
    os.path.join(BASE_DIR, "app/modules"),
]

def proccess_dirs(path):
    for root, dirs_list, files_list in os.walk(path):
        for file_name in filter(lambda f: f.endswith(".coffee"), files_list):
            file_path = os.path.join(root, file_name)

            with open(file_path, "r") as fr:
                data = fr.read()

                if CONTAIN_TEXT not in data:
                    relative_path = Path(file_path).relative_to(path)
                    with open(file_path, "w") as fw:
                        fw.seek(0)
                        fw.write(LICENSE.format(file_name=relative_path, data=data))


for dir_path in DIRS:
    proccess_dirs(dir_path)
