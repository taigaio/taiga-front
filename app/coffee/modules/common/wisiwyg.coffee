###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/common/wisiwyg.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaCommon")


#############################################################################
## WYSIWYG markitup editor directive
#############################################################################

# TODO: fix when i18n is implemented
$i18next = {
    t: (key) ->
        keywords = {
            "markdown-editor.heading-1": "First Level Heading",
            "markdown-editor.heading-2": "Second Level Heading",
            "markdown-editor.heading-3": "Third Level Heading",
            "markdown-editor.bold": "Bold",
            "markdown-editor.italic": "Italic",
            "markdown-editor.strike": "Strike",
            "markdown-editor.bulleted-list": "Bulleted List",
            "markdown-editor.numeric-list": "Numeric List",
            "markdown-editor.picture": "Picture",
            "markdown-editor.link": "Link",
            "markdown-editor.quotes": "Quotes",
            "markdown-editor.code-block": "Code Block / Code",
            "markdown-editor.preview": "Preview",
            "markdown-editor.help": "Help",
            "markdown-editor.placeholder": "Your title here...",
            "markdown-editor.link-placeholder": "Your text to link here..."
        }
        return keywords[key] or key
}

tgMarkitupDirective = ($rootscope, $rs) ->
    previewTemplate = _.template("""
    <div class="preview">
        <div class="actions">
            <a href="#" title="Edit">Edit</a>
        </div>
        <div class="content wysiwyg">
            <%= data %>
        </div>
    </div>
    """)

    link = ($scope, $el, $attrs, $model) ->
        element = angular.element($el)
        previewDomNode = $("<div/>", {class: "preview"})

        #openHelp = ->
        #    window.open($rootscope.urls.wikiHelpUrl(), '_blank')

        closePreviewMode = ->
            element.parents(".markdown").find(".preview").remove()
            element.parents(".markItUp").show()

        $scope.$on "markdown-editor:submit", ->
            closePreviewMode()

        preview = ->
            markdownDomNode = element.parents(".markdown")
            markItUpDomNode = element.parents(".markItUp")
            $rs.mdrender.render($scope.projectId, $model.$modelValue).then (data) ->
                markdownDomNode.append(previewTemplate({data: data.data}))
                markItUpDomNode.hide()

                # FIXME: Really `.parents()` is need? seems `.closest`
                # function is better aproach for it
                element.parents(".markdown").one "click", ".preview", (event) ->
                    event.preventDefault()
                    closePreviewMode()

        markdownCaretPositon = false

        setCaretPosition = (elm, caretPos) ->
            if elm.createTextRange
                range = elm.createTextRange()
                range.move('character', caretPos)
                range.select()

            else if elm.selectionStart
                elm.focus()
                elm.setSelectionRange(caretPos, caretPos)

        removeEmptyLine = (textarea, line, currentCaretPosition) ->
            lines = textarea.value.split("\n")
            removedLineLength = lines[line].length

            lines[line] = ""

            textarea.value = lines.join("\n")

            #return the new position
            return currentCaretPosition - removedLineLength + 1

        markdownSettings =
            nameSpace: 'markdown'
            onShiftEnter: {keepDefault:false, openWith:'\n\n'}
            onEnter:
                keepDefault: false
                replaceWith: (data) =>
                    lines = data.textarea.value[0..(data.caretPosition - 1)].split("\n")
                    lastLine = lines[lines.length - 1]

                    # unordered list -
                    match = lastLine.match /^(\s*- ).*/
                    if match
                        emptyListItem = lastLine.match /^(\s*)\-\s$/

                        if emptyListItem
                            markdownCaretPositon = removeEmptyLine(data.textarea, lines.length - 1, data.caretPosition)
                        else
                            return "\n#{match[1]}" if match

                    # unordered list *
                    match = lastLine.match /^(\s*\* ).*/

                    if match
                        emptyListItem = lastLine.match /^(\s*\* )$/

                        if emptyListItem
                            markdownCaretPositon = removeEmptyLine(data.textarea, lines.length - 1, data.caretPosition)
                        else
                            return "\n#{match[1]}" if match

                    # ordered list
                    match = lastLine.match /^(\s*)(\d+)\.\s/

                    if match
                        emptyListItem = lastLine.match /^(\s*)(\d+)\.\s$/

                        if emptyListItem
                            markdownCaretPositon = removeEmptyLine(data.textarea, lines.length - 1, data.caretPosition)
                        else
                            return "\n#{match[1] + (parseInt(match[2], 10) + 1)}. "

                    return "\n"

                afterInsert: (data) ->
                    # Calculate the scroll position

                    if markdownCaretPositon
                        setCaretPosition(data.textarea, markdownCaretPositon)
                        caretPosition = markdownCaretPositon
                        markdownCaretPositon = false
                    else
                        caretPosition = data.caretPosition

                    totalLines = data.textarea.value.split("\n").length
                    line = data.textarea.value[0..(caretPosition - 1)].split("\n").length
                    scrollRelation = line / totalLines
                    $el.scrollTop((scrollRelation * $el[0].scrollHeight) - ($el.height() / 2))

            markupSet: [
                {
                    name: $i18next.t('markdown-editor.heading-1')
                    key: "1"
                    placeHolder: $i18next.t('markdown-editor.placeholder')
                    closeWith: (markItUp) -> markdownTitle(markItUp, '=')
                },
                {
                    name: $i18next.t('markdown-editor.heading-2')
                    key: "2"
                    placeHolder: $i18next.t('markdown-editor.placeholder')
                    closeWith: (markItUp) -> markdownTitle(markItUp, '-')
                },
                {
                    name: $i18next.t('markdown-editor.heading-3')
                    key: "3"
                    openWith: '### '
                    placeHolder: $i18next.t('markdown-editor.placeholder')
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('markdown-editor.bold')
                    key: "B"
                    openWith: '**'
                    closeWith: '**'
                },
                {
                    name: $i18next.t('markdown-editor.italic')
                    key: "I"
                    openWith: '_'
                    closeWith: '_'
                },
                {
                    name: $i18next.t('markdown-editor.strike')
                    key: "S"
                    openWith: '~~'
                    closeWith: '~~'
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('markdown-editor.bulleted-list')
                    openWith: '- '
                },
                {
                    name: $i18next.t('markdown-editor.numeric-list')
                    openWith: (markItUp) -> markItUp.line+'. '
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('markdown-editor.picture')
                    key: "P"
                    replaceWith: '![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'
                },
                {
                    name: $i18next.t('markdown-editor.link')
                    key: "L"
                    openWith: '['
                    closeWith: ']([![Url:!:http://]!] "[![Title]!]")'
                    placeHolder: $i18next.t('markdown-editor.link-placeholder')
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('markdown-editor.quotes')
                    openWith: '> '
                },
                {
                    name: $i18next.t('markdown-editor.code-block')
                    openWith: '```\n'
                    closeWith: '\n```'
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('markdown-editor.preview')
                    call: preview
                    className: "preview-icon"
                },
                # {
                #     separator: '---------------'
                # },
                # {
                #     name: $i18next.t('markdown-editor.help')
                #     call: openHelp
                #     className: "help"
                # }
            ]
            afterInsert: (event) ->
                target = angular.element(event.textarea)
                $model.$setViewValue(target.val())

        markdownTitle = (markItUp, char) ->
            heading = ''
            n = $.trim(markItUp.selection or markItUp.placeHolder).length

            for i in [0..n-1]
                heading += char

            return '\n'+heading+'\n'

        element.markItUp(markdownSettings)

        element.on "keypress", (event) ->
            $scope.$apply()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgMarkitup", ["$rootScope", "$tgResources", tgMarkitupDirective])
