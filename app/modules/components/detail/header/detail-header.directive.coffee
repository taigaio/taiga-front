###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
