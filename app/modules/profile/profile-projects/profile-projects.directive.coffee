###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
