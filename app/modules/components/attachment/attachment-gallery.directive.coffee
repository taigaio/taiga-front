AttachmentGalleryDirective = () ->
    link = (scope, el, attrs, ctrl) ->

    return {
        scope: {},
        bindToController: {
            attachment: "=",
            onDelete: "&",
            onUpdate: "&",
            type: "="
        },
        controller: "Attachment",
        controllerAs: "vm",
        templateUrl: "components/attachment/attachment-gallery.html",
        link: link
    }

AttachmentGalleryDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentGallery", AttachmentGalleryDirective)
