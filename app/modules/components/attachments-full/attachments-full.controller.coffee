###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
