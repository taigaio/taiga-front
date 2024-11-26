###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
