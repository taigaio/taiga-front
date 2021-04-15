###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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

        if !attachment
            return null
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
