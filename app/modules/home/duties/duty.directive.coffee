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
# File: home/duties/duty.directive.coffee
###

DutyDirective = (navurls, $translate) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.duty = scope.duty
        scope.vm.type = scope.type

        scope.vm.getDutyType = () ->
            if scope.vm.duty
                if scope.vm.duty.get('_name') == "epics"
                    return $translate.instant("COMMON.EPIC")
                if scope.vm.duty.get('_name') == "userstories"
                    return $translate.instant("COMMON.USER_STORY")
                if scope.vm.duty.get('_name') == "tasks"
                    return $translate.instant("COMMON.TASK")
                if scope.vm.duty.get('_name') == "issues"
                    return $translate.instant("COMMON.ISSUE")

    return {
        templateUrl: "home/duties/duty.html"
        scope: {
            "duty": "=tgDuty",
            "type": "@"
        }
        link: link
    }

DutyDirective.$inject = [
    "$tgNavUrls",
    "$translate"
]

angular.module("taigaHome").directive("tgDuty", DutyDirective)
