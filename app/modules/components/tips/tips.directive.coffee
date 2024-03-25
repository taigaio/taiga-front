###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

timeout = @.taiga.timeout

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
      { contentType: "icon", icon: "icon-settings", message: "CUSTOM_FIELDS"}
      { contentType: "arrows", message: "SLIDE_ARROWS"}
    ]

    randomInt = (size) ->
        return Math.floor(Math.random() * size) + 1

    link = (scope, el, attrs) ->
        scope.tipLoaded = false
        waitingTimeout = null

        tgLoader.onStart () ->
            waitingTimeout = timeout 1000, ->
                loadTip()

        tgLoader.onEnd () ->
            clearTimeout(waitingTimeout)
            scope.tipLoaded = false

        loadTip = () ->
            scope.tipLoaded = true
            tip = tips[randomInt(tips.length - 1)]
            scope.tip = {
                contentType: tip.contentType
                message: "TIPS.TIP_#{tip.message}"
                icon: tip.icon
                color: "tip-color-#{randomInt(5)}"
            }

    return {
        link: link,
        scope: true,
        templateUrl: "components/tips/tip.html",
    }

module.directive('tgTips', ['tgLoader', '$translate', tipsDirective])