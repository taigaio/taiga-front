module = angular.module("taigaComponents")

moveToSprintLightboxDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        lightboxService.open(el)

    return {
        scope: {}
        bindToController: {
            openItems: "="
            sprint: "="
        },
        templateUrl: "components/move-to-sprint/move-to-sprint-lb/move-to-sprint-lb.html"
        controller: "MoveToSprintLbCtrl"
        controllerAs: "vm"
        link: link
    }

moveToSprintLightboxDirective.$inject = [
    "lightboxService"
]

module.directive("tgLbMoveToSprint", moveToSprintLightboxDirective)
