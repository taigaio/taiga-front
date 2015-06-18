ProfileTabsDirective = () ->
    return {
        scope: {}
        controller: "ProfileTabs"
        controllerAs: "vm"
        templateUrl: "profile/profile-tabs/profile-tabs.html"
        transclude: true
    }

angular.module("taigaProfile")
    .directive("tgProfileTabs", ProfileTabsDirective)
