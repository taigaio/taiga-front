###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ProfileTabDirective = () ->
    link = (scope, element, attrs, ctrl, transclude) ->
        scope.tab = {}

        attrs.$observe "tgProfileTab", (name) ->
            scope.tab.name = name

        attrs.$observe "tabTitle", (title) ->
            scope.tab.title = title

        scope.tab.icon = attrs.tabIcon
        scope.tab.active = !!attrs.tabActive

        if scope.$eval(attrs.tabDisabled) != true
            ctrl.addTab(scope.tab)

    return {
        templateUrl: "profile/profile-tab/profile-tab.html",
        scope: {},
        require: "^tgProfileTabs",
        link: link,
        transclude: true
    }

angular.module("taigaProfile")
    .directive("tgProfileTab", ProfileTabDirective)
