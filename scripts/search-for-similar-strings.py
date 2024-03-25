#!/usr/bin/env python
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC


import json
import os
import click
from difflib import SequenceMatcher

ROOT_PATH = os.path.dirname(os.path.dirname(__file__))
DEFAULT_LOCALE_PATH = os.path.join(ROOT_PATH, "app/locales/taiga/locale-en.json")


def keywords(key, value):
    if key is not None and not isinstance(value, dict):
        return [(".".join(key), value)]

    if key is not None and isinstance(value, dict):
        kws = []
        for item_key in value.keys():
            kws += keywords(key+[item_key], value[item_key])
        return kws

    if key is None and isinstance(value, dict):
        kws = []
        for item_key in value.keys():
            kws += keywords([item_key], value[item_key])
        return kws


@click.command()
@click.option('--threshold', default=1.0, help='Minimun similarity to show')
@click.option('--min-length', default=10, help='Minimun size of the string to show')
@click.option('--omit-identical', default=False, is_flag=True, help='Omit identical strings')
def verify_similarity(threshold, min_length, omit_identical):
    locales = json.load(open(DEFAULT_LOCALE_PATH))
    all_keywords = keywords(None, locales)
    already_shown_keys = set()

    for key1, value1 in all_keywords:
        for key2, value2 in all_keywords:
            if key1 == key2:
                continue
            if len(value1) < min_length and len(value2) < min_length:
                continue

            similarity = SequenceMatcher(None, value1, value2).ratio()
            if omit_identical and similarity == 1.0:
                continue

            if similarity >= threshold:
                if (key1, key2) not in already_shown_keys:
                    already_shown_keys.add((key1, key2))
                    already_shown_keys.add((key2, key1))
                    click.echo(
                        "The keys {} and {} has a similarity of {}\n - {}\n - {}".format(
                            key1,
                            key2,
                            similarity,
                            value1,
                            value2
                        )
                    )

if __name__ == "__main__":
    verify_similarity()
