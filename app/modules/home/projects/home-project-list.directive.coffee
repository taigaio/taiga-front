###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

HomeProjectListDirective = (currentUserService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))

    directive = {
        templateUrl: "home/projects/home-project-list.html"
        scope: {}
        link: link
    }

    return directive

HomeProjectListDirective.$inject = [
    "tgCurrentUserService"
]

angular.module("taigaHome").directive("tgHomeProjectList", HomeProjectListDirective)
