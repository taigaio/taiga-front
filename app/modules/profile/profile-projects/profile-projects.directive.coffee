###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

ProfileProjectsDirective = () ->
    link = (scope, elm, attr, ctrl) ->
        ctrl.loadProjects()

    return {
        templateUrl: "profile/profile-projects/profile-projects.html",
        scope: {
            user: "="
        },
        link: link
        bindToController: true,
        controllerAs: "vm",
        controller: "ProfileProjects"
    }

angular.module("taigaProfile").directive("tgProfileProjects", ProfileProjectsDirective)
