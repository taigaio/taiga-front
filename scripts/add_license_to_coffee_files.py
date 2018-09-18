import os, sys
from pathlib import Path

LICENSE = """###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
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
