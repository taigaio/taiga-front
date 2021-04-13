module = angular.module('taigaEpics')

RelatedUserStoriesDirective = () ->
    return {
        templateUrl:"epics/related-userstories/related-userstories.html",
        controller: "RelatedUserStoriesCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            userstories: '=',
            project: '='
            epic: '='
        }
    }

RelatedUserStoriesDirective.$inject = []

module.directive("tgRelatedUserstories", RelatedUserStoriesDirective)
