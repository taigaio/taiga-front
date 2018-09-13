###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: profile/profile-tab/profile-tab.directive.coffee
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
