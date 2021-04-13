JiraImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/jira-import/jira-import.html",
        controller: "JiraImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

JiraImportDirective.$inject = []

angular.module("taigaProjects").directive("tgJiraImport", JiraImportDirective)
