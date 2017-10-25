###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/common/analytics.coffee
###

taiga = @.taiga
module = angular.module("taigaCommon")


class EmojisService extends taiga.Service
    @.$inject = []

    constructor: () ->
        @.emojis = _.map taiga.emojis, (it) ->
            it.image = "/#{window._version}/emojis/" + it.image

            return it
        @.emojisById = _.keyBy(@.emojis, 'id')
        @.emojisByName = _.keyBy(@.emojis, 'name')


    searchByName: (name) =>
        return _.filter @.emojis, (it) -> it.name.indexOf(name) != -1

    getEmojiById: (id) =>
        return @.emojisById[id]

    getEmojiByName: (name) =>
        return @.emojisByName[name]

    replaceImgsByEmojiName: (html) =>
        emojiIds = taiga.getMatches(html, /emojis\/([^"]+).png"/gi)

        for emojiId in emojiIds
            regexImgs = new RegExp('<img(.*)' + emojiId + '[^>]+\>', 'g')
            emoji = @.getEmojiById(emojiId)
            html = html.replace(regexImgs, ':' + emoji.name + ':')

        return html

    replaceEmojiNameByImgs: (text) =>
        emojiIds = taiga.getMatches(text, /:([\w +-]*):/g)

        for emojiId in emojiIds
            regexImgs = new RegExp(':' + emojiId + ':', 'g')
            emoji = @.getEmojiByName(emojiId)

            if emoji
                text = text.replace(regexImgs, '![alt](' + emoji.image + ')')

        return text

    replaceEmojiNameByHtmlImgs: (text) =>
        emojiIds = taiga.getMatches(text, /:([\w +-]*):/g)

        for emojiId in emojiIds
            regexImgs = new RegExp(':' + _.escapeRegExp(emojiId) + ':', 'g')
            emoji = @.getEmojiByName(emojiId)

            if emoji
                text = text.replace(regexImgs, '<img src="' + emoji.image + '" />')

        return text

module.service("$tgEmojis", EmojisService)
