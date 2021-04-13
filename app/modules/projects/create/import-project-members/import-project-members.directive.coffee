ImportProjectMembersDirective = () ->
    return {
        link: (scope, elm, attr, ctrl) ->
            ctrl.fetchUser()

            scope.$watch('vm.members', ctrl.checkUsersLimit.bind(ctrl))

        templateUrl:"projects/create/import-project-members/import-project-members.html",
        controller: "ImportProjectMembersCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            members: '<',
            project: '<',
            onSubmit: '&',
            platform: '@',
            logo: '@',
            onCancel: '&'
        }
    }

ImportProjectMembersDirective.$inject = []

angular.module("taigaProjects").directive("tgImportProjectMembers", ImportProjectMembersDirective)
