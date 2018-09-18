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
# File: components/bind-code.directive.coffee
###

BindCode = ($sce, $parse, $compile, wysiwygService, wysiwygCodeHightlighterService) ->
  return {
    restrict: 'A',
    compile:  (tElement, tAttrs) ->
        tgBindCodeGetter = $parse(tAttrs.tgBindCode)
        tgBindCodeWatch = $parse tAttrs.tgBindCode, (value) ->
            return (value || '').toString()

        $compile.$$addBindingClass(tElement)

        return (scope, element, attr) ->
            $compile.$$addBindingInfo(element, attr.tgBindCode);

            scope.$watch tgBindCodeWatch, () ->
                html = wysiwygService.getHTML(tgBindCodeGetter(scope))

                element.html($sce.getTrustedHtml(html) || '')

                wysiwygCodeHightlighterService.addHightlighter(element)

  }

angular.module("taigaComponents")
    .directive("tgBindCode", [
        "$sce",
        "$parse",
        "$compile",
        "tgWysiwygService",
        "tgWysiwygCodeHightlighterService",
        BindCode])
