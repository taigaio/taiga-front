ProfileBarDirective = () ->
    return {
        templateUrl: "profile/profile-bar/profile-bar.html",
        controller: "ProfileBar",
        controllerAs: "vm"
    }


angular.module("taigaProfile").directive("tgProfileBar", ProfileBarDirective)
