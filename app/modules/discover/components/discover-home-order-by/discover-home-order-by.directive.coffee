DiscoverHomeOrderByDirective = () ->
    link = (scope, el, attrs) ->

    return {
        controller: "DiscoverHomeOrderBy",
        controllerAs: "vm",
        bindToController: true,
        templateUrl: "discover/components/discover-home-order-by/discover-home-order-by.html",
        scope: {
            currentOrderBy: "=orderBy",
            onChange: "&"
        },
        link: link
    }

DiscoverHomeOrderByDirective.$inject = []

angular.module("taigaDiscover").directive("tgDiscoverHomeOrderBy", DiscoverHomeOrderByDirective)
