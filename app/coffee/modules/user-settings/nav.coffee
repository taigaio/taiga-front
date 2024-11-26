###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
