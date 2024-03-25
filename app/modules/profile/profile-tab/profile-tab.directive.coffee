###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
