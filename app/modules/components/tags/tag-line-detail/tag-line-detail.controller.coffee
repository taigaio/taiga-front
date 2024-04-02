###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
