###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaComponents")

moveToSprintDirective = (taskboardTasksService) ->
    return {
        controller: "MoveToSprintCtrl"
        controllerAs: "vm"
        bindToController: true
        templateUrl: 'components/move-to-sprint/move-to-sprint.html'
        scope:  {
            sprint: '='
            uss: '='
            unnasignedTasks: '='
            issues: '='
            disabled: '='
            taskMap: '='
        }
    }

moveToSprintDirective.$inject = [
    'tgTaskboardTasks'
]

module.directive('tgMoveToSprint', [moveToSprintDirective])