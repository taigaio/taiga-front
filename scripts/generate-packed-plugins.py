#!/usr/bin/env python
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL

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
