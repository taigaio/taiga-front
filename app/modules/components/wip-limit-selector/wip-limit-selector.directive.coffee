taiga = @.taiga
timeout = @.taiga.timeout
cancelTimeout = @.taiga.cancelTimeout

#############################################################################
## Swimlane Selector
#############################################################################

WipLimitSelector = ($timeout) ->

    link = (scope, el, attrs) ->

        scope.displayWipLimitSelector = false

        scope.toggleWipSelectorVisibility = () ->
            scope.displayWipLimitSelector = !scope.displayWipLimitSelector

    return {
        link: link,
        scope: {}
        templateUrl: "components/wip-limit-selector/wip-limit-selector.html",
        controller: "ProjectSwimlanesWipLimit",
        bindToController: {
            status: '=',
        }
        controllerAs: "vm",
    }

angular.module('taigaComponents').directive("tgWipLimitSelector", [WipLimitSelector])
