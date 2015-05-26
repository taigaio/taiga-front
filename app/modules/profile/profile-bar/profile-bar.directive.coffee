ProfileBarDirective = () ->
    return {
        templateUrl: "profile/profile-bar/profile-bar.html",
        controller: "ProfileBar",
        controllerAs: "vm",
        scope: {
            user: "=user",
            isCurrentUser: "=iscurrentuser"
        },
        bindToController: true
    }


angular.module("taigaProfile").directive("tgProfileBar", ProfileBarDirective)
