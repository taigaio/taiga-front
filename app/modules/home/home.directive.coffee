HomeDirective = (homeService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        taiga.defineImmutableProperty(scope.vm, "workInProgress", () -> homeService.workInProgress)

        scope.$watch "vm.workInProgress", (workInProgress) ->
            if workInProgress.size > 0
                userStories = workInProgress.get("assignedTo").get("userStories")
                tasks = workInProgress.get("assignedTo").get("tasks")
                issues = workInProgress.get("assignedTo").get("issues")
                scope.vm.assignedTo = userStories.concat(tasks).concat(issues)

                userStories = workInProgress.get("watching").get("userStories")
                tasks = workInProgress.get("watching").get("tasks")
                issues = workInProgress.get("watching").get("issues")
                scope.vm.watching = userStories.concat(tasks).concat(issues)

    return {
        templateUrl: "home/home.html"
        scope: {}
        link: link
    }

HomeDirective.$inject = [
    "tgHomeService"
]

angular.module("taigaHome").directive("tgHome", HomeDirective)
