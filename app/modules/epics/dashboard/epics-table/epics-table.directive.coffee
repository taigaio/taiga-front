###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

EpicsTableDirective = () ->
    return {
        templateUrl:"epics/dashboard/epics-table/epics-table.html",
        controller: "EpicsTableCtrl",
        controllerAs: "vm",
        scope: {}
    }


angular.module('taigaEpics').directive("tgEpicsTable", EpicsTableDirective)
