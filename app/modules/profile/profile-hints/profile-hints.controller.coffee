class ProfileHints
    maxHints: 2
    supportUrls: [
        "https://taiga.io/support/import-export-projects/",
        "https://taiga.io/support/custom-fields/"
    ]
    constructor: (@translate) ->
        hintKey = Math.floor(Math.random() * @.maxHints) + 1

        @.url = @.supportUrls[hintKey - 1]

        @translate("HINTS.HINT#{hintKey}_TITLE").then (text) =>
            @.title = text

        @translate("HINTS.HINT#{hintKey}_TEXT").then (text) =>
            @.text = text

ProfileHints.$inject = [
    "$translate"
]

angular.module("taigaProfile").controller("ProfileHints", ProfileHints)
