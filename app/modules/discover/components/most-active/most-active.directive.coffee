MostActiveDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "MostActive"
        controllerAs: "vm",
        templateUrl: "discover/components/most-active/most-active.html",
        scope: {},
        link: link
    }

MostActiveDirective.$inject = []

angular.module("taigaDiscover").directive("tgMostActive", MostActiveDirective)
