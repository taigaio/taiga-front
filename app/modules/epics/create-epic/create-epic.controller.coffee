###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: create-epic.controller.coffee
###

taiga = @.taiga
trim = taiga.trim
getRandomDefaultColor = taiga.getRandomDefaultColor

module = angular.module("taigaEpics")

class CreateEpicController
    @.$inject = [
        "tgResources"
        "tgAttachmentsService"
        "$q"
    ]

    constructor: (@rs, @attachmentsService, @q) ->
        @.newEpic = {
            color: getRandomDefaultColor()
            project: @.project.id
            status: @.project.default_epic_status
            tags: []
        }
        @.attachments = Immutable.List()

    createEpic: () ->
        promise =  @rs.epics.post(@.newEpic)

        promise.then (response) =>
            @._createAttachments(response.data)

        promise.then (data) =>
            @.onCreateEpic()

    # Color selector
    selectColor: (color) ->
        @.newEpic.color = color

    # Tags
    addTag: (name, color) ->
        name = trim(name.toLowerCase())

        if not _.find(@.newEpic.tags, (it) -> it[0] == name)
            @.newEpic.tags.push([name, color])

    deleteTag: (tag) ->
        _.remove @.newEpic.tags, (it) -> it[0] == tag[0]

    # Attachments
    addAttachment: (attachment) ->
        @.attachments.push(attachment)

    _createAttachments: (epic) ->
        promises = _.map @.attachments.toJS(), (attachment) ->
            return attachmentsService.upload(attachment.file, epic.id, epic.project, 'epic')
        return @q.all(promises)

module.controller("CreateEpicCtrl", CreateEpicController)
