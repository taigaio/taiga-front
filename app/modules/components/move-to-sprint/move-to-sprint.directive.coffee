###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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