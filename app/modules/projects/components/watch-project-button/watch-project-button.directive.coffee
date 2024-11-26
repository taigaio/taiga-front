###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

WatchProjectButtonDirective = ->
    return {
        scope: {}
        controller: "WatchProjectButton",
        bindToController: {
            project: "="
        }
        controllerAs: "vm",
        templateUrl: "projects/components/watch-project-button/watch-project-button.html",
    }

angular.module("taigaProjects").directive("tgWatchProjectButton", WatchProjectButtonDirective)
