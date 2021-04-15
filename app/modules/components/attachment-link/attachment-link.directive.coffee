###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

AttachmentLinkDirective = ($parse, attachmentsPreviewService, lightboxService) ->
    link = (scope, el, attrs) ->
        attachment = $parse(attrs.tgAttachmentLink)(scope)

        el.on "click", (event) ->
            if taiga.isImage(attachment.getIn(['file', 'name']))
                event.preventDefault()

                scope.$apply ->
                    lightboxService.open($('tg-attachments-preview'))
                    attachmentsPreviewService.fileId = attachment.getIn(['file', 'id'])
            else if taiga.isPdf(attachment.getIn(['file', 'name']))
                event.preventDefault()
                window.open(attachment.getIn(['file', 'url']))

        scope.$on "$destroy", -> el.off()
    return {
        link: link
    }

AttachmentLinkDirective.$inject = [
    "$parse",
    "tgAttachmentsPreviewService",
    "lightboxService"
]

angular.module("taigaComponents").directive("tgAttachmentLink", AttachmentLinkDirective)
