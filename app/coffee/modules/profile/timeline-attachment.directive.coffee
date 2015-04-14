TimelineAttachmentDirective = ($tgTemplate, $compile) ->
    validFileExtensions = [".jpg", ".jpeg", ".bmp", ".gif", ".png"]

    isImage = (url) ->
        url = url.toLowerCase()

        return _.some validFileExtensions, (extension) =>
            return url.indexOf(extension, url - extension.length) != -1

    link = ($scope, $el, $attrs) ->
        is_image = isImage($scope.attachment.url)

        if is_image
            template = $tgTemplate.get("profile/timeline/timeline-attachment-image.html")
        else
            template = $tgTemplate.get("profile/timeline/timeline-attachment.html")

        $el.html(template)
        $compile($el.contents())($scope)

    return {
        link: link
        scope: {
            attachment: "=tgTimelineAttachment"
        }
    }

angular.module("taigaProfile")
    .directive("tgTimelineAttachment", ["$tgTemplate", "$compile", TimelineAttachmentDirective])
