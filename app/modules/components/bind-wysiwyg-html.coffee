###
# Copyright (C) 2014-present Taiga Agile LLC
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

BindCode = ($sce, $parse, $compile, wysiwygService) ->
  return {
    restrict: 'A',
    compile:  (tElement, tAttrs) ->
        tgBindWysiwygHtmlGetter = $parse(tAttrs.tgBindWysiwygHtml)
        tgBindWysiwygHtmlWatch = $parse tAttrs.tgBindWysiwygHtml, (value) ->
            return (value || '').toString()

        $compile.$$addBindingClass(tElement)

        render = (element, html) =>
            element.html($sce.getTrustedHtml(html) || '')

            element[0].querySelectorAll('pre code').forEach (block) =>
                hljs.highlightBlock(block)

            anchor = element[0].querySelectorAll('a[href^="#"]')
            anchor.forEach (link) =>
                link.addEventListener 'click', (e) =>
                    e.preventDefault()
                    node = document.querySelector(link.getAttribute('href'))

                    if node
                        node.scrollIntoView()

        return (scope, element, attr) ->
            $compile.$$addBindingInfo(element, attr.tgBindWysiwygHtml);

            scope.$watch tgBindWysiwygHtmlWatch, () ->
                html = wysiwygService.getHTML(tgBindWysiwygHtmlGetter(scope))
                wysiwygService.refreshAttachmentURL(html).then (html) =>
                    render(element, html)

                render(element, html)
  }

angular.module("taigaComponents")
    .directive("tgBindWysiwygHtml", [
        "$sce",
        "$parse",
        "$compile",
        "tgWysiwygService",
        BindCode])
