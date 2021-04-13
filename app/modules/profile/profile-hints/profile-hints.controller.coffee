class ProfileHints
    HINTS: [
        { #hint1
            url: "https://resources.taiga.io/extend/import-export-projects/"
        },
        { #hint2
            url: "https://resources.taiga.io/features/customisation/#tier-4-custom-fields-and-due-dates"
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
