DiscoverSearchBarDirective = () ->
    link = (scope, el, attrs, ctrl) ->

    return {
        controller: "DiscoverSearchBar",
        controllerAs: "vm"
        templateUrl: 'discover/components/discover-search-bar/discover-search-bar.html',
        bindToController: true,
        scope: {
            q: "=",
            filter: "=",
            onChange: "&"
        },
        compile: (element, attrs) ->
            if !attrs.q
                attrs.q = ''
        link: link
    }

DiscoverSearchBarDirective.$inject = []

angular.module('taigaDiscover').directive('tgDiscoverSearchBar', DiscoverSearchBarDirective)
