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
# File: components/detail/header/detail-header.directive.coffee
###

module = angular.module('taigaBase')

DetailHeaderDirective = ($tgWysiwygService) ->
    @.$inject = []

    link = (scope, el, attrs, ctrl) ->
        scope.blocked_html_note = ''

        scope.$watch "vm.item.blocked_note" , (blocked_note) ->
            html_note = $tgWysiwygService.getHTML(blocked_note)
            scope.blocked_html_note = html_note

        ctrl._checkPermissions()

    return {
        link: link,
        controller: "DetailHeaderCtrl",
        bindToController: true,
        scope: {
            item: "=",
            project: "=",
            sectionName: "="
            requiredPerm: "@"
        },
        controllerAs: "vm",
        templateUrl:"components/detail/header/detail-header.html"
    }


module.directive("tgDetailHeader", ["tgWysiwygService", DetailHeaderDirective])
