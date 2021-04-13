GithubImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/github-import/github-import.html",
        controller: "GithubImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

GithubImportDirective.$inject = []

angular.module("taigaProjects").directive("tgGithubImport", GithubImportDirective)
