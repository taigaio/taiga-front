###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
