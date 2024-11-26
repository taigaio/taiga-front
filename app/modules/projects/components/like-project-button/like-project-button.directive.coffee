###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

LikeProjectButtonDirective = ->
    return {
        scope: {}
        controller: "LikeProjectButton",
        bindToController: {
            project: '='
        }
        controllerAs: "vm",
        templateUrl: "projects/components/like-project-button/like-project-button.html",
    }

angular.module("taigaProjects").directive("tgLikeProjectButton", LikeProjectButtonDirective)
