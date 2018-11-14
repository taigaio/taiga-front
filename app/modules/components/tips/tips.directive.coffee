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
# File: components/tips/tips.directive.coffee
###

module = angular.module("taigaComponents")

tipsDirective = (tgLoader, $translate) ->
    tips = [
      { contentType: "icon", icon: "icon-project", message: "PROJECTS_ORDER"}
      { contentType: "icon", icon: "icon-upvote", message: "VOTING"}
      { contentType: "icon", icon: "icon-attach", message: "ISSUES_TO_SPRINT"}
      { contentType: "icon", icon: "icon-clock", message: "DUE_DATE"}
      { contentType: "icon", icon: "icon-iocaine", message: "IOCAIN"}
      { contentType: "icon", icon: "icon-blocked-project", message: "BLOCKED"}
      { contentType: "icon", icon: "icon-promote", message: "PROMOTE"}
      { contentType: "icon", icon: "icon-bulk", message: "BULK"}
      { contentType: "range", message: "ZOOM"}
      { message: "CUSTOM_FIELDS"}
      { contentType: "arrows", message: "SLIDE_ARROWS"}
    ]

    randomInt = (size) ->
        return Math.floor(Math.random() * size) + 1

    link = (scope, el, attrs) ->
        tgLoader.onStart () ->
            loadTip()

        loadTip = () ->
            tip = tips[randomInt(tips.length - 1)]
            scope.contentType = tip.contentType
            scope.message = "TIPS.TIP_#{tip.message}"
            scope.icon = tip.icon

            scope.tipColor = "tip-color-#{randomInt(5)}"

    return {
        link: link,
        scope: true,
        templateUrl: "components/tips/tip.html",
    }

module.directive('tgTips', ['tgLoader', '$translate', tipsDirective])