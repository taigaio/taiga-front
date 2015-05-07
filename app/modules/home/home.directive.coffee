HomeDirective = ($q, homeService, projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        projectsPromise = projectsService.getCurrentUserProjects()
        workInProgresPromise = homeService.getWorkInProgress()

        $q.all([projectsPromise, workInProgresPromise]).then ->
            homeService.attachProjectInfoToWorkInProgress(projectsService.currentUserProjectsById)

            taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.currentUserProjects)
            taiga.defineImmutableProperty(scope.vm, "workInProgress", () -> homeService.workInProgress)

            if scope.vm.workInProgress.size > 0
                userStories = scope.vm.workInProgress.get("assignedTo").get("userStories")
                tasks = scope.vm.workInProgress.get("assignedTo").get("tasks")
                issues = scope.vm.workInProgress.get("assignedTo").get("issues")
                scope.vm.assignedTo = userStories.concat(tasks).concat(issues)

                userStories = scope.vm.workInProgress.get("watching").get("userStories")
                tasks = scope.vm.workInProgress.get("watching").get("tasks")
                issues = scope.vm.workInProgress.get("watching").get("issues")
                scope.vm.watching = userStories.concat(tasks).concat(issues)

    return {
        templateUrl: "home/home.html"
        scope: {}
        link: link
    }

HomeDirective.$inject = [
    "$q",
    "tgHomeService",
    "tgProjectsService"
]

angular.module("taigaHome").directive("tgHome", HomeDirective)
