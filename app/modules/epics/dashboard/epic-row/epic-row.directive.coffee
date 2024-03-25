###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

EpicRowDirective = () ->
    return {
        templateUrl:"epics/dashboard/epic-row/epic-row.html",
        controller: "EpicRowCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            epic: '=',
            options: '='
        }
    }

angular.module('taigaEpics').directive("tgEpicRow", EpicRowDirective)
