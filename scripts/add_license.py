#!/usr/bin/env python
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC

import os
import sys
import re
from pathlib import Path
from typing import List

import typer


SH_LICENSE = """# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos INC

"""
SH_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"


PY_LICENSE = """# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos INC

"""
PY_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"

COFFEE_LICENSE = """###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos INC
###

"""
COFFEE_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"

PUG_LICENSE = """
//- This Source Code Form is subject to the terms of the Mozilla Public
//- License, v. 2.0. If a copy of the MPL was not distributed with this
//- file, You can obtain one at http://mozilla.org/MPL/2.0/.
//-
//- Copyright (c) 2021-present Kaleidos INC

"""
PUG_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"

JS_LICENSE = """/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

"""
JS_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"

TS_LICENSE = """/**
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

"""
TS_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"

HTML_LICENSE = """<!--
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) 2021-present Kaleidos INC
-->

"""
HTML_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"

CSS_LICENSE = """
/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) 2021-present Kaleidos INC
*/

"""
CSS_FIND_REGEXP = r"Copyright \(c\) 2021-present Kaleidos INC"


BASE_DIR = os.path.dirname(os.path.realpath(__file__))


app = typer.Typer()


def _generate_file_data(license, data, *args):
    return f"{license}{data}"


def _generate_file_data_for_py_files(license, data, *args):
    new_data = data.replace("# -*- coding: utf-8 -*-\n", "")
    new_license = f"# -*- coding: utf-8 -*-\n{license}"

    if "#!/usr/bin/env python" in data:
        new_data = new_data.replace("#!/usr/bin/env python\n", "")
        new_license = f"#!/usr/bin/env python\n{license}"

    return f"{new_license}{new_data}"


def _generate_file_data_with_replacement(license, data, find_regexp, *args):
    return re.sub(find_regexp, license, data, re.M)


def _proccess_dir(path, FILE_REGEXP, LICENSE, FIND_REGEXP, generate_file_data=_generate_file_data, positive_search=False):
    exit = 0

    print(f' > Checking license prephace for "{FILE_REGEXP}" files.')
    for root, dirs_list, files_list in os.walk(path):
        for file_name in filter(lambda f: re.match(FILE_REGEXP, f), files_list):
            file_path = os.path.join(root, file_name)

            with open(file_path, "r") as fr:
                data = fr.read()

                if ((not positive_search and not re.search(FIND_REGEXP, data)) or
                        (positive_search and re.search(FIND_REGEXP, data))):
                    with open(file_path, "w") as fw:
                        fw.seek(0)
                        fw.write(generate_file_data(LICENSE, data, FIND_REGEXP))

                    print(f'    + Change license prephace in "{file_path}"')
                    exit = 1
                else:
                    print(f'  - Ignore "{file_path}"')
    return exit


@app.command()
def update_license(dirs: List[Path] = typer.Option(
        [],
        exists=True,
        file_okay=False,
        dir_okay=True,
        writable=True,
        readable=True,
        resolve_path=True
)):
    ex_status = 0
    for dir_path in dirs:
        ex_status += _proccess_dir(dir_path, r'.*\.sh$', SH_LICENSE, SH_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.py$', PY_LICENSE, PY_FIND_REGEXP, generate_file_data=_generate_file_data_for_py_files)

        ex_status += _proccess_dir(dir_path, r'.*\.coffee$', COFFEE_LICENSE, COFFEE_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.js$', JS_LICENSE, JS_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.pug$', PUG_LICENSE, PUG_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.jade$', PUG_LICENSE, PUG_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.ts$', TS_LICENSE, TS_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.html$', HTML_LICENSE, HTML_FIND_REGEXP)
        ex_status += _proccess_dir(dir_path, r'.*\.css$', CSS_LICENSE, CSS_FIND_REGEXP)

    sys.exit(ex_status)


if __name__ == "__main__":
    app()
