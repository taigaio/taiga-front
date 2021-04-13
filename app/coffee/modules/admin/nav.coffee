AdminNavigationDirective = ->
    link = ($scope, $el, $attrs) ->
        section = $attrs.tgAdminNavigation
        $el.find(".active").removeClass("active")
        $el.find("#adminmenu-#{section}").addClass("active")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module = angular.module("taigaAdmin")
module.directive("tgAdminNavigation", AdminNavigationDirective)
