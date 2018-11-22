###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: tag-line.controller.coffee
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
