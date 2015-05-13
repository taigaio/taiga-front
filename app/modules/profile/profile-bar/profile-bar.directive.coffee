ProfileBarDirective = () ->
    return {
        templateUrl: "profile/profile-bar/profile-bar.html",
        controller: "ProfileBar",
        controllerAs: "vm",
        scope: {}
    }


angular.module("taigaProfile").directive("tgProfileBar", ProfileBarDirective)
