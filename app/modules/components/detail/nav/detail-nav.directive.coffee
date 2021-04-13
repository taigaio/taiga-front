module = angular.module('taigaBase')

DetailNavDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        scope.$watch "vm.item", (value) ->
            return if not value
            ctrl._checkNav()

    return {
        link: link,
        controller: "DetailNavCtrl",
        bindToController: true,
        scope: {
            item: "="
        },
        controllerAs: "vm",
        templateUrl:"components/detail/nav/detail-nav.html"
    }

module.directive("tgDetailNav", DetailNavDirective)
