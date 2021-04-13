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
