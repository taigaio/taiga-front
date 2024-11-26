###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaProject")

createProjectMembersRestrictionsDirective = () ->
    return {
        scope: {
            isPrivate: '=',
            limitMembersPrivateProject: '=',
            limitMembersPublicProject: '='
        },
        templateUrl: "projects/create/create-project-members-restrictions/create-project-members-restrictions.html"
    }

module.directive('tgCreateProjectMembersRestrictions', [createProjectMembersRestrictionsDirective])
