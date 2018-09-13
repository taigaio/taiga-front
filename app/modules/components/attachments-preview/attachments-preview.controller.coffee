###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/attachments-preview/attachments-preview.controller.coffee
###

class AttachmentsPreviewController
    @.$inject = [
        "tgAttachmentsPreviewService"
    ]

    constructor: (@attachmentsPreviewService) ->
        taiga.defineImmutableProperty @, "current", () =>
            if !@attachmentsPreviewService.fileId
                return null

            return @.getCurrent()

    hasPagination: () ->
        images = @.attachments.filter (attachment) =>
            return taiga.isImage(attachment.getIn(['file', 'name']))

        return images.size > 1

    getCurrent: () ->
        attachment = @.attachments.find (attachment) =>
            @attachmentsPreviewService.fileId == attachment.getIn(['file', 'id'])

        file = attachment.get('file')

        return file

    getIndex: () ->
        return @.attachments.findIndex (attachment) =>
            @attachmentsPreviewService.fileId == attachment.getIn(['file', 'id'])

    next: () ->
        attachmentIndex = @.getIndex()

        image = @.attachments.slice(attachmentIndex + 1).find (attachment) ->
                return taiga.isImage(attachment.getIn(['file', 'name']))

        if !image
            image = @.attachments.find (attachment) ->
                return taiga.isImage(attachment.getIn(['file', 'name']))


        @attachmentsPreviewService.fileId = image.getIn(['file', 'id'])

    previous: () ->
        attachmentIndex = @.getIndex()

        image = @.attachments.slice(0, attachmentIndex).findLast (attachment) ->
                return taiga.isImage(attachment.getIn(['file', 'name']))

        if !image
            image = @.attachments.findLast (attachment) ->
                return taiga.isImage(attachment.getIn(['file', 'name']))

        @attachmentsPreviewService.fileId = image.getIn(['file', 'id'])

angular.module('taigaComponents').controller('AttachmentsPreview', AttachmentsPreviewController)
