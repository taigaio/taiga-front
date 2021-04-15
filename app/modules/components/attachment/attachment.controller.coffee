###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class AttachmentController
    @.$inject = [
        'tgAttachmentsService',
        '$translate'
    ]

    constructor: (@attachmentsService, @translate) ->
        @.form = {}
        @.form.description = @.attachment.getIn(['file', 'description'])
        @.form.is_deprecated = @.attachment.get(['file', 'is_deprecated'])

        @.title = @translate.instant("ATTACHMENT.TITLE", {
            fileName: @.attachment.get('name'),
            date: moment(@.attachment.get('created_date')).format(@translate.instant("ATTACHMENT.DATE"))
        })

    editMode: (mode) ->
        attachment = @.attachment.set('editable', mode)
        @.onUpdate({attachment: attachment})

    delete: () ->
        @.onDelete({attachment: @.attachment})

    save: () ->
        attachment = @.attachment.set('loading', true)

        @.onUpdate({attachment: attachment})

        attachment = @.attachment.merge({
            editable: false,
            loading: false
        })

        attachment = attachment.mergeIn(['file'], {
            description: @.form.description,
            is_deprecated: !!@.form.is_deprecated
        })

        @.onUpdate({attachment: attachment})

angular.module('taigaComponents').controller('Attachment', AttachmentController)
