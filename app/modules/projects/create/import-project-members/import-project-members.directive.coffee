###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
