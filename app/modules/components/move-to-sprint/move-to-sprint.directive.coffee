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