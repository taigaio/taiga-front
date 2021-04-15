###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class AttachmentsSimpleController
    @.$inject = [
        "tgAttachmentsService"
    ]

    constructor: (@attachmentsService) ->

    addAttachment: (file) ->
        attachment = Immutable.fromJS({
            file: file,
            name: file.name,
            size: file.size
        })

        if @attachmentsService.validate(file)
            @.attachments = @.attachments.push(attachment)

            @.onAdd({attachment: attachment}) if @.onAdd

    addAttachments: (files) ->
        _.forEach files, @.addAttachment.bind(this)

    deleteAttachment: (toDeleteAttachment) ->
        @.attachments = @.attachments.filter (attachment) -> attachment != toDeleteAttachment

        @.onDelete({attachment: toDeleteAttachment}) if @.onDelete

angular.module("taigaComponents").controller("AttachmentsSimple", AttachmentsSimpleController)
