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

    directive = {
        templateUrl: "home/duties/duty.html"
        scope: {
            "duty": "=tgDuty"
        }
        link: link
    }

    return directive

angular.module("taigaHome").directive("tgDuty", ["$tgNavUrls", "tgProjectsService", "$translate", DutyDirective])
