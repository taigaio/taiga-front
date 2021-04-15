###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

CompileHtmlDirective = ($compile) ->
    link = (scope, element, attrs) ->
        scope.$watch attrs.tgCompileHtml, (newValue, oldValue) ->
            element.html(newValue)
            $compile(element.contents())(scope)

    return {
        link: link
    }

CompileHtmlDirective.$inject = ["$compile"]

angular.module("taigaCommon").directive("tgCompileHtml", CompileHtmlDirective)
