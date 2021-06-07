###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

sizeFormat = @.taiga.sizeFormat

class AttachmentsFullController
    @.$inject = [
        "$translate",
        "$tgConfirm",
        "$tgConfig",
        "$tgStorage",
        "tgAttachmentsFullService",
        "tgProjectService",
        "tgAttachmentsPreviewService"
    ]

    constructor: (@translate, @confirm, @config, @storage, @attachmentsFullService, @projectService, @attachmentsPreviewService) ->
        @.mode = @storage.get('attachment-mode', 'list')

        @.maxFileSize = @config.get("maxUploadFileSize", null)
        @.maxFileSize = sizeFormat(@.maxFileSize) if @.maxFileSize
        @.maxFileSizeMsg = if @.maxFileSize then @translate.instant("ATTACHMENT.MAX_UPLOAD_SIZE", {maxFileSize: @.maxFileSize}) else ""

        taiga.defineImmutableProperty @, 'attachments', () => return @attachmentsFullService.attachments
        taiga.defineImmutableProperty @, 'deprecatedsCount', () => return @attachmentsFullService.deprecatedsCount
        taiga.defineImmutableProperty @, 'attachmentsVisible', () => return @attachmentsFullService.attachmentsVisible
        taiga.defineImmutableProperty @, 'deprecatedsVisible', () => return @attachmentsFullService.deprecatedsVisible

    uploadingAttachments: () ->
        return @attachmentsFullService.uploadingAttachments

    addAttachment: (file) ->
        editable = (@.mode == 'list')

        @attachmentsFullService.addAttachment(@.projectId, @.objId, @.type, file, editable)

    setMode: (mode) ->
        @.mode = mode

        @storage.set('attachment-mode', mode)

    toggleDeprecatedsVisible: () ->
        @attachmentsFullService.toggleDeprecatedsVisible()

    addAttachments: (files) ->
        _.forEach files, (file) => @.addAttachment(file)

    loadAttachments: ->
        @attachmentsFullService.loadAttachments(@.type, @.objId, @.projectId)

    deleteAttachment: (toDeleteAttachment) ->
        @attachmentsPreviewService.fileId = null

        title = @translate.instant("ATTACHMENT.TITLE_LIGHTBOX_DELETE_ATTACHMENT")
        message = @translate.instant("ATTACHMENT.MSG_LIGHTBOX_DELETE_ATTACHMENT", {
            fileName: toDeleteAttachment.getIn(['file', 'name'])
        })

        return @confirm.askOnDelete(title, message)
            .then (askResponse) =>
                onError = () =>
                    message = @translate.instant("ATTACHMENT.ERROR_DELETE_ATTACHMENT", {errorMessage: message})
                    @confirm.notify("error", null, message)
                    askResponse.finish(false)

                onSuccess = () => askResponse.finish()

                @attachmentsFullService.deleteAttachment(toDeleteAttachment, @.type).then(onSuccess, onError)

    reorderAttachment: (attachment, newIndex) ->
        @attachmentsFullService.reorderAttachment(@.objId, @.type, attachment, newIndex)

    updateAttachment: (toUpdateAttachment) ->
        @attachmentsFullService.updateAttachment(toUpdateAttachment, @.type)

    _isEditable: ->
        if @projectService.project
            return @projectService.hasPermission(@.editPermission)
        return false

    showAttachments: ->
        return @._isEditable() || @attachmentsFullService.attachments.size

angular.module("taigaComponents").controller("AttachmentsFull", AttachmentsFullController)
