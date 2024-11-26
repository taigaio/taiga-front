###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
