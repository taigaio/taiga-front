ProfileTimelineAttachmentDirective = (template, $compile) ->
    validFileExtensions = [".jpg", ".jpeg", ".bmp", ".gif", ".png"]

    isImage = (url) ->
        url = url.toLowerCase()

        return _.some validFileExtensions, (extension) ->
            return url.indexOf(extension, url - extension.length) != -1

    link = (scope, el) ->
        is_image = isImage(scope.attachment.url)

        if is_image
            templateHtml = template.get("profile/profile-timeline-attachment/profile-timeline-attachment-image.html")
        else
            templateHtml = template.get("profile/profile-timeline-attachment/profile-timeline-attachment.html")

        el.html(templateHtml)
        $compile(el.contents())(scope)

    return {
        link: link
        scope: {
            attachment: "=tgProfileTimelineAttachment"
        }
    }

ProfileTimelineAttachmentDirective.$inject = [
    "$tgTemplate",
    "$compile"
]

angular.module("taigaProfile")
    .directive("tgProfileTimelineAttachment", ProfileTimelineAttachmentDirective)
