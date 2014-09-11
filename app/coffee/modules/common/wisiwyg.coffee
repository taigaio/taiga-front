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
$i18next = {t: (key) -> key}

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

        openHelp = ->
            window.open($rootscope.urls.wikiHelpUrl(), '_blank')

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
                    markdownDomNode.find(".preview").remove()
                    markItUpDomNode.show()

        markdownSettings =
            nameSpace: 'markdown'
            onShiftEnter: {keepDefault:false, openWith:'\n\n'}
            onEnter:
                keepDefault: false
                replaceWith: (data) ->
                    lastLine = data.textarea.value[0..(data.caretPosition - 1)].split("\n").pop()

                    match = lastLine.match /^(\s*- ).*/
                    return "\n#{match[1]}" if match

                    match = lastLine.match /^(\s*\* ).*/
                    return "\n#{match[1]}" if match

                    match = lastLine.match /^(\s*1\. ).*/
                    return "\n#{match[1]}" if match

                    return "\n"

                afterInsert: (data) ->
                    # Calculate the scroll position
                    totalLines = data.textarea.value.split("\n").length
                    line = data.textarea.value[0..(data.caretPosition - 1)].split("\n").length
                    scrollRelation = line / totalLines
                    $el.scrollTop((scrollRelation * $el[0].scrollHeight) - ($el.height() / 2))

            markupSet: [
                {
                    name: $i18next.t('wiki-editor.heading-1')
                    key: "1"
                    placeHolder: $i18next.t('wiki-editor.placeholder')
                    closeWith: (markItUp) -> markdownTitle(markItUp, '=')
                },
                {
                    name: $i18next.t('wiki-editor.heading-2')
                    key: "2"
                    placeHolder: $i18next.t('wiki-editor.placeholder')
                    closeWith: (markItUp) -> markdownTitle(markItUp, '-')
                },
                {
                    name: $i18next.t('wiki-editor.heading-3')
                    key: "3"
                    openWith: '### '
                    placeHolder: $i18next.t('wiki-editor.placeholder')
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.bold')
                    key: "B"
                    openWith: '**'
                    closeWith: '**'
                },
                {
                    name: $i18next.t('wiki-editor.italic')
                    key: "I"
                    openWith: '_'
                    closeWith: '_'
                },
                {
                    name: $i18next.t('wiki-editor.strike')
                    key: "S"
                    openWith: '~~'
                    closeWith: '~~'
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.bulleted-list')
                    openWith: '- '
                },
                {
                    name: $i18next.t('wiki-editor.numeric-list')
                    openWith: (markItUp) -> markItUp.line+'. '
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.picture')
                    key: "P"
                    replaceWith: '![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'
                },
                {
                    name: $i18next.t('wiki-editor.link')
                    key: "L"
                    openWith: '['
                    closeWith: ']([![Url:!:http://]!] "[![Title]!]")'
                    placeHolder: $i18next.t('wiki-editor.link-placeholder')
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.quotes')
                    openWith: '> '
                },
                {
                    name: $i18next.t('wiki-editor.code-block')
                    openWith: '```\n'
                    closeWith: '\n```'
                },
                {
                    separator: '---------------'
                },
                {
                    name: $i18next.t('wiki-editor.preview')
                    call: preview
                    className: "preview-icon"
                },
                # {
                #     separator: '---------------'
                # },
                # {
                #     name: $i18next.t('wiki-editor.help')
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
