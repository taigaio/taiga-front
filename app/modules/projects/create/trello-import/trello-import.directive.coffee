###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

TrelloImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/trello-import/trello-import.html",
        controller: "TrelloImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

TrelloImportDirective.$inject = []

angular.module("taigaProjects").directive("tgTrelloImport", TrelloImportDirective)
