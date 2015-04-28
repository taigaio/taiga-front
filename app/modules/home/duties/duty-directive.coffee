DutyDirective = (navurls, projectsService, $translate) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.duty = scope.duty

        scope.vm.getDutyType = () ->
            if scope.vm.duty
                if scope.vm.duty._name == "userstories"
                    return $translate.instant("COMMON.USER_STORY")
                if scope.vm.duty._name == "tasks"
                    return $translate.instant("COMMON.TASK")
                if scope.vm.duty._name == "issues"
                    return $translate.instant("COMMON.ISSUE")

        scope.vm.getUrl = () ->
            if scope.vm.duty
                ctx = {
                    project: projectsService.projectsById.get(String(scope.vm.duty.project)).slug
                    ref: scope.vm.duty.ref
                }
                return navurls.resolve("project-#{scope.vm.duty._name}-detail", ctx)

        scope.vm.getProjectName = () ->
            if scope.vm.duty
                return projectsService.projectsById.get(String(scope.vm.duty.project)).name

    directive = {
        templateUrl: "home/duties/duty.html"
        scope: {
            "duty": "=tgDuty"
        }
        link: link
    }

    return directive

angular.module("taigaHome").directive("tgDuty", ["$tgNavUrls", "tgProjectsService", "$translate", DutyDirective])
