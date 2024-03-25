#!/usr/bin/env python
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC

from pathlib import Path
import os
import json

import logging
logging.basicConfig(format='%(asctime)s %(message)s',
                    datefmt='%Y/%m/%d %I:%M:%S %p',
                    level=logging.DEBUG)


# Generate js file, css file and a list of images
js = ""
css = ""
images = []
plugins = []

logging.info("- Reading plugins:")

for d in Path("./dist/plugins").iterdir():
    if d.is_dir() and d.name != "packed":
        logging.info(f"  <- {d.name}")

        # Read .json file
        f = d / f'{d.name}.json'
        data = (json.load(f.open()))

        # Get js
        if "js" in data:
            js += (Path("./dist/", data['js']).open()
                                              .read()
                                              .replace(f'{d.name}/images',
                                                       'packed/images'))
            js += "\n";
            del data["js"]

        # Get css
        if "css" in data:
            css += (Path("./dist/", data['css']).open()
                                                .read())
            css += "\n";
            del data["css"]

        plugins.append(data)

        # Get images
        imgs_d = d / 'images'

        if imgs_d.exists() and imgs_d.is_dir():
            images.extend(list(imgs_d.iterdir()))


# Generate packed plugin
logging.info(f"- Generating packed plugin:")
packed = Path("./dist/plugins/packed")
packed.mkdir(exist_ok=True)

#  - Generated js file
logging.info(f"  -> Generating js file.")
with (packed / "plugins.js").open("w") as f:
    f.write(js)

#  - Generated css file
logging.info(f"  -> Generating css file.")
with (packed / "plugins.css").open("w") as f:
    f.write(css)

#   - Copy images
if images:
    logging.info(f"  -> Copying images.")
    d = packed / ("images")
    d.mkdir(exist_ok=True)

    for i in images:
        new_i = d / i.name
        with new_i.open(mode='wb') as f:
            f.write(i.read_bytes())

#  - Generated json file
logging.info(f"  -> Generating json file.")
packedPlugin = {
    "isPack": True,
    "js": "plugins/packed/plugins.js",
    "css": "plugins/packed/plugins.css",
    "plugins": plugins
}

with (packed / "packed.json").open("w") as f:
    json.dump(packedPlugin, f)
