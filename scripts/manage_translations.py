#!/usr/bin/env python

import os
from argparse import ArgumentParser
from argparse import RawTextHelpFormatter

from subprocess import PIPE, Popen, call


def _tx_resource_for_name(name):
    """ Return the Transifex resource name """
    return "taiga-front.{}".format(name)


def fetch(resources=None, languages=None):
    """
    Fetch translations from Transifex, wrap long lines, generate mo files.
    """
    if not resources:
        if languages is None:
            call("tx pull -a -f --minimum-perc=5", shell=True)
        else:
            for lang in languages:
                call("tx pull -f -l {lang}".format(lang=lang), shell=True)

    else:
        for resource in resources:
            if languages is None:
                call("tx pull -r {res} -a -f --minimum-perc=5".format(res=_tx_resource_for_name(resource)), shell=True)
            else:
                for lang in languages:
                    call("tx pull -r {res} -f -l {lang}".format(res=_tx_resource_for_name(resource), lang=lang), shell=True)


def commit(resources=None, languages=None):
    """
    Commit messages to Transifex,
    """
    if not resources:
        if languages is None:
            call("tx push -s -l en", shell=True)
        else:
            for lang in languages:
                call("tx push -t -l {lang}".format(lang=lang), shell=True)
    else:
        for resource in resources:
            # Transifex push
            if languages is None:
                call("tx push -r {res} -s -l en".format(res=_tx_resource_for_name(resource)), shell=True)
            else:
                for lang in languages:
                    call("tx push -r {res} -t -l {lang}".format(res= _tx_resource_for_name(resource), lang=lang), shell=True)


if __name__ == "__main__":
    try:
        devnull = open(os.devnull)
        Popen(["tx"], stdout=devnull, stderr=devnull).communicate()
    except OSError as e:
        if e.errno == os.errno.ENOENT:
            print("""
You need transifex-client, install it.

 1. Install transifex-client, use

       $ pip install --upgrade transifex-client==0.11.1.beta

 2. Create ~/.transifexrc file:

       $ vim ~/.transifexrc"

       [https://www.transifex.com]
       hostname = https://www.transifex.com
       token =
       username = <YOUR_USERNAME>
       password = <YOUR_PASSWOR>
                  """)
            exit(1)

    RUNABLE_SCRIPTS = {
        "commit": "send .po file to transifex ('en' by default).",
        "fetch": "get .po files from transifex and regenerate .mo files.",
    }

    parser = ArgumentParser(description="manage translations in taiga-back between the repo and transifex.",
                            formatter_class=RawTextHelpFormatter)
    parser.add_argument("cmd", nargs=1,
        help="\n".join(["{0} - {1}".format(c, h) for c, h in RUNABLE_SCRIPTS.items()]))
    parser.add_argument("-r", "--resources", action="append",
        help="limit operation to the specified resources")
    parser.add_argument("-l", "--languages", action="append",
        help="limit operation to the specified languages")
    options = parser.parse_args()

    if options.cmd[0] in RUNABLE_SCRIPTS.keys():
        eval(options.cmd[0])(options.resources, options.languages)
    else:
        print("Available commands are: {}".format(", ".join(RUNABLE_SCRIPTS.keys())))
