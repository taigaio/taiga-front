###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

sizeFormat = @.taiga.sizeFormat

class AttachmentsService
    @.$inject = [
        "$tgConfirm",
        "$tgConfig",
        "$translate",
        "tgResources"
    ]

    constructor: (@confirm, @config, @translate, @rs) ->
        @.types = {
            epics: "epic",
            userstories: "us",
            userstory: "us",
            issues: "issue",
            tasks: "task",
            epic: "epic",
            us: "us"
            issue: "issue",
            task: "task",
            wiki: "wiki",
            wikipage: "wiki"
        }
        @.maxFileSize = @.getMaxFileSize()

        if @.maxFileSize
            @.maxFileSizeFormated = sizeFormat(@.maxFileSize)

    sizeError: (file) ->
        message = @translate.instant("ATTACHMENT.ERROR_MAX_SIZE_EXCEEDED", {
            fileName: file.name,
            fileSize: sizeFormat(file.size),
            maxFileSize: @.maxFileSizeFormated
        })

        @confirm.notify("error", message)

    validate: (file) ->
        if @.maxFileSize && file.size > @.maxFileSize
            @.sizeError(file)

            return false

        return true

    getMaxFileSize: () ->
        return @config.get("maxUploadFileSize", null)

    list: (type, objId, projectId) ->
        return @rs.attachments.list(type, objId, projectId).then (attachments) =>
            return attachments.sortBy (attachment) => attachment.get('order')

    get: (type, id) ->
        return @rs.attachments.get(@.types[type], id)

    delete: (type, id) ->
        return @rs.attachments.delete(type, id)

    saveError: (file, data) ->
        message = ""

        if file
            message = @translate.instant("ATTACHMENT.ERROR_UPLOAD_ATTACHMENT", {
                        fileName: file.name, errorMessage: data.data._error_message
                      })

        @confirm.notify("error", message)

    upload: (file, objId, projectId, type, from_comment = false) ->
        promise = @rs.attachments.create(type, projectId, objId, file, from_comment)

        promise.then null, @.saveError.bind(this, file)

        return promise

    bulkUpdateOrder: (objectId, type, afterAttachmentId, bulkAttachments) ->
        promise = @rs.attachments.bulkAttachments(objectId, type, afterAttachmentId, bulkAttachments)

        promise.then null, @.saveError.bind(this, null)

        return promise

    patch: (id, type, patch) ->
        promise = @rs.attachments.patch(type, id, patch)

        promise.then null, @.saveError.bind(this, null)

        return promise

angular.module("taigaCommon").service("tgAttachmentsService", AttachmentsService)
