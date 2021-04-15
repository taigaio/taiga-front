###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

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
