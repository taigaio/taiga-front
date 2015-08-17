WorkingOnDirective = (homeService, currentUserService) ->
    link = (scope, el, attrs, ctrl) ->
        user = currentUserService.getUser()
        # If we are not logged in the user will be null
        if user
          userId = user.get("id")
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
