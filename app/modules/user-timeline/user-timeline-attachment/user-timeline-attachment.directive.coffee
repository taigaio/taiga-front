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
# File: user-timeline/user-timeline-attachment/user-timeline-attachment.directive.coffee
###

UserTimelineAttachmentDirective = (template, $compile) ->
    validFileExtensions = [".jpg", ".jpeg", ".bmp", ".gif", ".png"]

    isImage = (url) ->
        url = url.toLowerCase()

        return _.some validFileExtensions, (extension) ->
            return url.indexOf(extension, url - extension.length) != -1

    link = (scope, el) ->
        is_image = isImage(scope.attachment.get('url'))

        if is_image
            templateHtml = template.get("user-timeline/user-timeline-attachment/user-timeline-attachment-image.html")
        else
            templateHtml = template.get("user-timeline/user-timeline-attachment/user-timeline-attachment.html")

        el.html(templateHtml)
        $compile(el.contents())(scope)

        el.find("img").error () -> @.remove()

    return {
        link: link
        scope: {
            attachment: "=tgUserTimelineAttachment"
        }
    }

UserTimelineAttachmentDirective.$inject = [
    "$tgTemplate",
    "$compile"
]

angular.module("taigaUserTimeline")
    .directive("tgUserTimelineAttachment", UserTimelineAttachmentDirective)
