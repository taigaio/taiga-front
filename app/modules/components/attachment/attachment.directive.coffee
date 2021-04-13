AttachmentDirective = () ->
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
        templateUrl: "components/attachment/attachment.html",
        link: link
    }

AttachmentDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachment", AttachmentDirective)
