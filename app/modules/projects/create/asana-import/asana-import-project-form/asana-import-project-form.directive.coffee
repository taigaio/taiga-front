AsanaImportProjectFormDirective = () ->
    return {
        link: (scope, elm, attr, ctrl) ->
            scope.$watch('vm.members', ctrl.checkUsersLimit.bind(ctrl))

        templateUrl:"projects/create/asana-import/asana-import-project-form/asana-import-project-form.html",
        controller: "AsanaImportProjectFormCtrl",
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

AsanaImportProjectFormDirective.$inject = []

angular.module("taigaProjects").directive("tgAsanaImportProjectForm", AsanaImportProjectFormDirective)
