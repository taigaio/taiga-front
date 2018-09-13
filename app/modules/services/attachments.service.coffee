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
# File: services/attachments.service.coffee
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

    patch: (id, type, patch) ->
        promise = @rs.attachments.patch(type, id, patch)

        promise.then null, @.saveError.bind(this, null)

        return promise

angular.module("taigaCommon").service("tgAttachmentsService", AttachmentsService)
