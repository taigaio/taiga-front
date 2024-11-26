###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
