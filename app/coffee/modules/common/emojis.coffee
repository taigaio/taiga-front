###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
