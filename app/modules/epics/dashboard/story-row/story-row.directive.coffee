module = angular.module('taigaEpics')

StoryRowDirective = () ->
    return {
        templateUrl:"epics/dashboard/story-row/story-row.html",
        controller: "StoryRowCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            story: '=',
            options: '='
        }
    }

module.directive("tgStoryRow", StoryRowDirective)
