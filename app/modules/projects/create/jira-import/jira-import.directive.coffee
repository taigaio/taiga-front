###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

JiraImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/jira-import/jira-import.html",
        controller: "JiraImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

JiraImportDirective.$inject = []

angular.module("taigaProjects").directive("tgJiraImport", JiraImportDirective)
