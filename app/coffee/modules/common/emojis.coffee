###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
