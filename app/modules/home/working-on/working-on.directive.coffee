WorkingOnDirective = (homeService, currentUserService) ->
    link = (scope, el, attrs, ctrl) ->
        userId = currentUserService.getUser().get("id")

        ctrl.getWorkInProgress(userId)

    return {
        controller: "WorkingOn",
        controllerAs: "vm",
        templateUrl: "home/working-on/working-on.html",
        scope: {},
        link: link
    }

WorkingOnDirective.$inject = [
    "tgHomeService",
    "tgCurrentUserService"
]

angular.module("taigaHome").directive("tgWorkingOn", WorkingOnDirective)
