###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

            window._extraValidHtmlElments = {input: true}
            window._extraValidAttrs = {checked: true}

            element.html($sce.getTrustedHtml(html) || '')
            element[0].querySelectorAll('pre code').forEach (block) =>
                blockClasses = block.className + ' ';
                blockClasses += if block.parentNode then block.parentNode.className else ''
                match = /\blang(?:uage)?-([\w-]+)\b/i.exec(blockClasses)
                matchResult = 'plaintext'

                if match && match.length
                    matchResult = match[1]

                language = hljs.getLanguage(matchResult)

                if language
                    resultHighlight = hljs.highlightBlock(block)
                else
                    ljs.load "/#{window._version}/highlightjs-languages/" +  matchResult + ".min.js", ->
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

                html = wysiwygService.relativePaths(html)

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
