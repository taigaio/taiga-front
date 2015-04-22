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

# How to test lists (-, *, 1.)
# test it with text after & before the list
# + is the cursor position

# CASE 1
# - aa+
# --> enter
# - aa
# - +

# CASE 1
# - +
# --> enter

# +

# CASE 3
# - bb+cc
# --> enter
# - bb
# - cc

# CASE 3
# +- aa
# --> enter

# - aa

#############################################################################
## WYSIWYG markitup editor directive
#############################################################################
tgMarkitupDirective = ($rootscope, $rs, $selectedText, $template, $compile) ->
    previewTemplate = $template.get("common/wysiwyg/wysiwyg-markitup-preview.html", true)

    link = ($scope, $el, $attrs, $model) ->
        element = angular.element($el)
        previewDomNode = $("<div/>", {class: "preview"})

        closePreviewMode = ->
            element.parents(".markdown").find(".preview").remove()
            element.parents(".markItUp").show()

        $scope.$on "markdown-editor:submit", ->
            closePreviewMode()

        preview = ->
            markdownDomNode = element.parents(".markdown")
            markItUpDomNode = element.parents(".markItUp")
            $rs.mdrender.render($scope.projectId, $model.$modelValue).then (data) ->
                html = previewTemplate({data: data.data})
                html = $compile(html)($scope)

                markdownDomNode.append(html)
                markItUpDomNode.hide()

                markdown = element.closest(".markdown")

                markdown.on "mouseup.preview", ".preview", (event) ->
                    event.preventDefault()
                    target = angular.element(event.target)

                    if !target.is('a') and $selectedText.get().length
                        return

                    markdown.off(".preview")
                    closePreviewMode()

        setCaretPosition = (textarea, caretPosition) ->
            if textarea.createTextRange
                range = textarea.createTextRange()
                range.move("character", caretPosition)
                range.select()

            else if textarea.selectionStart
                textarea.focus()
                textarea.setSelectionRange(caretPosition, caretPosition)

            # Calculate the scroll position
            totalLines = textarea.value.split("\n").length
            line = textarea.value[0..(caretPosition - 1)].split("\n").length
            scrollRelation = line / totalLines
            $el.scrollTop((scrollRelation * $el[0].scrollHeight) - ($el.height() / 2))

        addLine = (textarea, nline, replace) ->
            lines = textarea.value.split("\n")

            if replace
                lines[nline] = replace + lines[nline]
            else
                lines[nline] = ""

            cursorPosition = 0

            for line, key in lines
                cursorPosition += line.length + 1 || 1

                break if key == nline

            textarea.value = lines.join("\n")

            #return the new position
            if replace
                return cursorPosition - lines[nline].length + replace.length - 1
            else
                return cursorPosition

        markdownSettings =
            nameSpace: "markdown"
            onShiftEnter: {keepDefault:false, openWith:"\n\n"}
            onEnter:
                keepDefault: false,
                replaceWith: () -> "\n"
                afterInsert: (data) ->
                    lines = data.textarea.value.split("\n")
                    cursorLine = data.textarea.value[0..(data.caretPosition - 1)].split("\n").length
                    newLineContent = data.textarea.value[data.caretPosition..].split("\n")[0]
                    lastLine = lines[cursorLine - 1]

                    # unordered list -
                    match = lastLine.match /^(\s*- ).*/

                    if match
                        emptyListItem = lastLine.match /^(\s*)\-\s$/

                        if emptyListItem
                            markdownCaretPositon = addLine(data.textarea, cursorLine - 1)
                        else
                            markdownCaretPositon = addLine(data.textarea, cursorLine, "#{match[1]}")

                    # unordered list *
                    match = lastLine.match /^(\s*\* ).*/

                    if match
                        emptyListItem = lastLine.match /^(\s*\* )$/

                        if emptyListItem
                            markdownCaretPositon = addLine(data.textarea, cursorLine - 1)
                        else
                            markdownCaretPositon = addLine(data.textarea, cursorLine, "#{match[1]}")

                    # ordered list
                    match = lastLine.match /^(\s*)(\d+)\.\s/

                    if match
                        emptyListItem = lastLine.match /^(\s*)(\d+)\.\s$/

                        if emptyListItem
                            markdownCaretPositon = addLine(data.textarea, cursorLine - 1)
                        else
                            markdownCaretPositon = addLine(data.textarea, cursorLine, "#{match[1] + (parseInt(match[2], 10) + 1)}. ")


                    setCaretPosition(data.textarea, markdownCaretPositon) if markdownCaretPositon

            #I18N
            markupSet: [
                {
                    name: "First Level Heading"
                    key: "1"
                    placeHolder: "Your title here..."
                    closeWith: (markItUp) -> markdownTitle(markItUp, "=")
                },
                {
                    name: "Second Level Heading"
                    key: "2"
                    placeHolder: "Your title here..."
                    closeWith: (markItUp) -> markdownTitle(markItUp, "-")
                },
                {
                    name: "Third Level Heading"
                    key: "3"
                    openWith: "### "
                    placeHolder: "Your title here..."
                },
                {
                    separator: "---------------"
                },
                {
                    name: "Bold"
                    key: "B"
                    openWith: "**"
                    closeWith: "**"
                },
                {
                    name: "Italic"
                    key: "I"
                    openWith: "_"
                    closeWith: "_"
                },
                {
                    name: "Strike"
                    key: "S"
                    openWith: "~~"
                    closeWith: "~~"
                },
                {
                    separator: "---------------"
                },
                {
                    name: "Bulleted List"
                    openWith: "- "
                },
                {
                    name: "Numeric List"
                    openWith: (markItUp) -> markItUp.line+". "
                },
                {
                    separator: "---------------"
                },
                {
                    name: "Picture"
                    key: "P"
                    replaceWith: '![[![Alternative text]!]](<<<[![Url:!:http://]!]>>> "[![Title]!]")'
                    beforeInsert:(markItUp) -> prepareUrlFormatting(markItUp)
                    afterInsert:(markItUp) -> urlFormatting(markItUp)
                },
                {
                    name: "Link"
                    key: "L"
                    openWith: "["
                    closeWith: '](<<<[![Url:!:http://]!]>>> "[![Title]!]")'
                    placeHolder: "Your text to link here..."
                    beforeInsert:(markItUp) -> prepareUrlFormatting(markItUp)
                    afterInsert:(markItUp) -> urlFormatting(markItUp)
                },
                {
                    separator: "---------------"
                },
                {
                    name: "Quotes"
                    openWith: "> "
                },
                {
                    name: "Code Block / Code"
                    openWith: "```\n"
                    closeWith: "\n```"
                },
                {
                    separator: "---------------"
                },
                {
                    name: "Preview"
                    call: preview
                    className: "preview-icon"
                },
                # {
                #     separator: "---------------"
                # },
                # {
                #     name: $tr.t("markdown-editor.help")
                #     call: openHelp
                #     className: "help"
                # }
            ]
            afterInsert: (event) ->
                target = angular.element(event.textarea)
                $model.$setViewValue(target.val())

        prepareUrlFormatting = (markItUp) ->
            console.log(markItUp)
            regex = /(<<<|>>>)/gi
            result = 0
            indices = []
            (indices.push(result.index)) while ( (result = regex.exec(markItUp.textarea.value)) )
            markItUp.donotparse = indices
            console.log(indices)

        urlFormatting = (markItUp) ->
            console.log(markItUp.donotparse)
            regex = /<<</gi
            result = 0
            startIndex = 0

            loop
                result = regex.exec(markItUp.textarea.value)
                break if !result
                if result.index not in markItUp.donotparse
                    startIndex = result.index
                    break

            regex = />>>/gi
            endIndex = 0
            loop
                result = regex.exec(markItUp.textarea.value)
                break if !result
                if result.index not in markItUp.donotparse
                    endIndex = result.index
                    break

            value = markItUp.textarea.value
            url = value.substring(startIndex, endIndex).replace('<<<', '').replace('>>>', '')
            url = url.replace('(', '%28').replace(')', '%29')
            url = url.replace('[', '%5B').replace(']', '%5D')
            value = value.substring(0, startIndex) + url + value.substring(endIndex+3, value.length)
            markItUp.textarea.value = value
            markItUp.donotparse = undefined

        markdownTitle = (markItUp, char) ->
            heading = ""
            n = $.trim(markItUp.selection or markItUp.placeHolder).length

            for i in [0..n-1]
                heading += char

            return "\n"+heading+"\n"

        element.markItUp(markdownSettings)
        element.on "keypress", (event) ->
            $scope.$apply()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgMarkitup", ["$rootScope", "$tgResources", "$selectedText", "$tgTemplate", "$compile",
                                tgMarkitupDirective])
