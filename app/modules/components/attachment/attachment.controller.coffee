###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
