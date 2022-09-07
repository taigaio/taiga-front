###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProfileHints
    HINTS: [
        { #hint1
            url: "https://community.taiga.io/t/import-export-taiga-projects/168"
        },
        { #hint2
            url: "https://community.taiga.io/t/customisation-for-your-projects/127#tier-4-custom-fields-and-due-dates-5"
        },
        { #hint3
        },
        { #hint4
        }
    ]
    constructor: (@translate) ->
        hintKey = Math.floor(Math.random() * @.HINTS.length) + 1

        @.hint = @.HINTS[hintKey - 1]

        @.hint.linkText = @.hint.linkText || 'HINTS.LINK'

        @.hint.title = @translate.instant("HINTS.HINT#{hintKey}_TITLE")

        @.hint.text = @translate.instant("HINTS.HINT#{hintKey}_TEXT")

ProfileHints.$inject = [
    "$translate"
]

angular.module("taigaProfile").controller("ProfileHints", ProfileHints)
