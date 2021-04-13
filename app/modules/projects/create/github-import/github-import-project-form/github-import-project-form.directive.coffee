GithubImportProjectFormDirective = () ->
    return {
        link: (scope, elm, attr, ctrl) ->
            scope.$watch('vm.members', ctrl.checkUsersLimit.bind(ctrl))

        templateUrl:"projects/create/github-import/github-import-project-form/github-import-project-form.html",
        controller: "GithubImportProjectFormCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            members: '<',
            project: '<',
            onSaveProjectDetails: '&',
            onCancelForm: '&',
            fetchingUsers: '<'
        }
    }

GithubImportProjectFormDirective.$inject = []

angular.module("taigaProjects").directive("tgGithubImportProjectForm", GithubImportProjectFormDirective)
