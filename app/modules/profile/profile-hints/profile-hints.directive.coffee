ProfileHints = ($translate) ->
    return {
        scope: {},
        controller: "ProfileHints",
        controllerAs: "vm",
        templateUrl: "profile/profile-hints/profile-hints.html"
    }

ProfileHints.$inject = [
    "$translate"
]

angular.module("taigaProfile").directive("tgProfileHints", ProfileHints)
