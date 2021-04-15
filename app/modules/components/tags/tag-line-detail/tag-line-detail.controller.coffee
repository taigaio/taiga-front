###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

trim = @.taiga.trim

module = angular.module('taigaCommon')

class TagLineController

    @.$inject = [
        "$rootScope",
        "$tgConfirm",
        "$tgQueueModelTransformation",
    ]

    constructor: (@rootScope, @confirm, @modelTransform) ->
        @.loadingAddTag = false

    onDeleteTag: (tag) ->
        @.loadingRemoveTag = tag[0]

        onDeleteTagSuccess = (item) =>
            @rootScope.$broadcast("object:updated")
            @.loadingRemoveTag = false

            return item

        onDeleteTagError = () =>
            @confirm.notify("error")
            @.loadingRemoveTag = false

        tagName = trim(tag[0].toLowerCase())

        transform = @modelTransform.save (item) ->
            itemtags = _.clone(item.tags)

            _.remove itemtags, (tag) -> tag[0] == tagName

            item.tags = itemtags

            return item

        return transform.then(onDeleteTagSuccess, onDeleteTagError)

    onAddTag: (tag, color) ->
        @.loadingAddTag = true

        onAddTagSuccess = (item) =>
            @rootScope.$broadcast("object:updated") #its a kind of magic.
            @rootScope.$broadcast("tags:updated")
            @.addTag = false
            @.loadingAddTag = false

            return item

        onAddTagError = () =>
            @.loadingAddTag = false
            @confirm.notify("error")

        transform = @modelTransform.save (item) =>
            value = trim(tag.toLowerCase())

            itemtags = _.clone(item.tags)

            itemtags.push([tag , color])

            item.tags = itemtags

            return item

        return transform.then(onAddTagSuccess, onAddTagError)

module.controller("TagLineCtrl", TagLineController)
