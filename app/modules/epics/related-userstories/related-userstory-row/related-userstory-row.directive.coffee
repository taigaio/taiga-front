module = angular.module('taigaEpics')

RelatedUserstoryRowDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.setAvatarData()

    return {
        link: link,
        templateUrl:"epics/related-userstories/related-userstory-row/related-userstory-row.html",
        controller: "RelatedUserstoryRowCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            userstory: '='
            epic: '='
            project: '='
            loadRelatedUserstories:"&"
        }
    }

RelatedUserstoryRowDirective.$inject = []

module.directive("tgRelatedUserstoryRow", RelatedUserstoryRowDirective)
