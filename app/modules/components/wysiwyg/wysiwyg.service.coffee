###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/components/wysiwyg/wysiwyg.service.coffee
###

class WysiwygService
    constructor: (@wysiwygCodeHightlighterService) ->

    searchEmojiByName: (name) ->
        return _.filter @.emojis, (it) -> it.name.indexOf(name) != -1

    setEmojiImagePath: (emojis) ->
        @.emojis = _.map emojis, (it) ->
            it.image = "/#{window._version}/emojis/" + it.image

            return it

    loadEmojis: () ->
        $.getJSON("/#{window._version}/emojis/emojis-data.json").then(@.setEmojiImagePath.bind(this))

    getEmojiById: (id) ->
        return _.find  @.emojis, (it) -> it.id == id

    getEmojiByName: (name) ->
        return _.find @.emojis, (it) -> it.name == name

    replaceImgsByEmojiName: (html) ->
        emojiIds = taiga.getMatches(html, /emojis\/([^"]+).png"/gi)

        for emojiId in emojiIds
            regexImgs = new RegExp('<img(.*)' + emojiId + '[^>]+\>', 'g')
            emoji = @.getEmojiById(emojiId)
            html = html.replace(regexImgs, ':' + emoji.name + ':')

        return html

    replaceEmojiNameByImgs: (text) ->
        emojiIds = taiga.getMatches(text, /:([^: ]*):/g)

        for emojiId in emojiIds
            regexImgs = new RegExp(':' + emojiId + ':', 'g')
            emoji = @.getEmojiByName(emojiId)

            if emoji
                text = text.replace(regexImgs, '![alt](' + emoji.image + ')')

        return text

    removeTrailingListBr: (text) ->
        regex = new RegExp(/<li>(.*?)<br><\/li>/, 'g')
        return text.replace(regex, '<li>$1</li>')

    getMarkdown: (html) ->
        # https://github.com/yabwe/medium-editor/issues/543
        cleanIssueConverter = {
            filter: ['html', 'body', 'span', 'div'],
            replacement: (innerHTML) ->
                return innerHTML
        }

        codeLanguageConverter = {
            filter:  (node) =>
                return node.nodeName == 'PRE' &&
                  node.firstChild &&
                  node.firstChild.nodeName == 'CODE'
            replacement: (content, node) =>
                lan = @wysiwygCodeHightlighterService.getLanguageInClassList(node.firstChild.classList)
                lan = '' if !lan

                return '\n\n```' + lan + '\n' + _.trim(node.firstChild.textContent) + '\n```\n\n'
         }

        html = html.replace(/&nbsp;(<\/.*>)/g, "$1")
        html = @.replaceImgsByEmojiName(html)
        html = @.removeTrailingListBr(html)

        markdown = toMarkdown(html, {
            gfm: true,
            converters: [cleanIssueConverter, codeLanguageConverter]
        })

        return markdown

    getHTML: (text) ->
        return "" if !text || !text.length

        options = {
            breaks: true
        }

        text = @.replaceEmojiNameByImgs(text)

        md = window.markdownit({
            breaks: true
        })

        result = md.render(text)

        return result

angular.module("taigaComponents")
    .service("tgWysiwygService", ["tgWysiwygCodeHightlighterService", WysiwygService])
