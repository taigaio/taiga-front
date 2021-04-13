DiscoverSearchDirective = () ->
    link = (scope, element, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "DiscoverSearch",
        controllerAs: "vm"
        link: link
    }

DiscoverSearchDirective.$inject = []

angular.module("taigaDiscover").directive("tgDiscoverSearch", DiscoverSearchDirective)
