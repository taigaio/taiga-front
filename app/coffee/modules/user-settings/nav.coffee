UserSettingsNavigationDirective = ->
    link = ($scope, $el, $attrs) ->
        section = $attrs.tgUserSettingsNavigation
        $el.find(".active").removeClass("active")
        $el.find("#usersettingsmenu-#{section}").addClass("active")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module = angular.module("taigaUserSettings")
module.directive("tgUserSettingsNavigation", UserSettingsNavigationDirective)
