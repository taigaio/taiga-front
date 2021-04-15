###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ImportProjectSelectorDirective = () ->
    return {
        templateUrl:"projects/create/import-project-selector/import-project-selector.html",
        controller: "ImportProjectSelectorCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            projects: '<',
            onCancel: '&',
            onSelectProject: '&',
            logo: '@',
            noProjectsMsg: '@',
            search: '@'
        }
    }

angular.module("taigaProjects").directive("tgImportProjectSelector", ImportProjectSelectorDirective)
