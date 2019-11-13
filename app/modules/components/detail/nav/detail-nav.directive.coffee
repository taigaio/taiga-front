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
# File: components/detail/nav/detail-nav.directive.coffee
###

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
