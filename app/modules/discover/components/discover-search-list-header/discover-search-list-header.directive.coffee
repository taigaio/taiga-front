DiscoverSearchListHeaderDirective = () ->
    link = (scope, el, attrs) ->

    return {
        controller: "DiscoverSearchListHeader",
        controllerAs: "vm",
        bindToController: true,
        templateUrl: "discover/components/discover-search-list-header/discover-search-list-header.html",
        scope: {
            onChange: "&",
            orderBy: "="
        },
        link: link
    }

DiscoverSearchListHeaderDirective.$inject = []

angular.module("taigaDiscover").directive("tgDiscoverSearchListHeader", DiscoverSearchListHeaderDirective)
