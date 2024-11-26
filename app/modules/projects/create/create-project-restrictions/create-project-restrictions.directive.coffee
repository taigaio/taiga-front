###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaProject")

createProjectRestrictionsDirective = () ->
    return {
        scope: {
            isPrivate: '=',
            canCreatePrivateProjects: '=',
            canCreatePublicProjects: '='
        },
        templateUrl: "projects/create/create-project-restrictions/create-project-restrictions.html"
    }

module.directive('tgCreateProjectRestrictions', [createProjectRestrictionsDirective])
