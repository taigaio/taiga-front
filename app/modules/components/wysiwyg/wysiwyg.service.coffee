###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: components/wysiwyg/wysiwyg.service.coffee
###

class WysiwygService
    @.$inject = [
        "tgProjectService",
        "tgAttachmentsFullService",
        "tgAttachmentsService",
        "$sce"
    ]

    constructor: (@projectService, @attachmentsFullService, @attachmentsService, @sce) ->
        @.projectDataConversion = {}
        # prevent duplicate calls to the same attachment
        @.cache = {}

    getMarkdown: (html) ->
        projectId = @projectService.project.get('id')

        if !@.projectDataConversion[projectId]
            @.dataConversion = window.angularDataConversion()
            @.dataConversion.setUp(@projectService.project.get('slug'))
            @.projectDataConversion[projectId] = @.dataConversion

        return @.projectDataConversion[projectId].toMarkdown(html)

    getHTML: (text) ->
        return "" if !text || !text.length

        projectId = @projectService.project.get('id')

        if !@.projectDataConversion[projectId]
            @.dataConversion = window.angularDataConversion()
            @.dataConversion.setUp(@projectService.project.get('slug'))
            @.projectDataConversion[projectId] = @.dataConversion

        return @.projectDataConversion[projectId].toHtml(text)

    getAttachmentData: (tokens) ->
        return @attachmentsService.get(tokens[0], tokens[1]).then (response) => response.data.url

    getCachedAttachment: (tokens) ->
        attachmentId = parseInt(tokens[1], 10)

        attachments = @attachmentsFullService.attachments.toJS()
        attachment = attachments.find (attachment) => attachment.file.id == attachmentId

        if attachment
            return Promise.resolve(attachment.file.url)
        else
            cache_key = tokens[0] + tokens[1]
            cached_result = @.cache[cache_key]

            if cached_result
                return Promise.resolve(cached_result)
            else
                return @.getAttachmentData(tokens).then (url) =>
                    @.cache[cache_key] = url
                    return url

    refreshAttachmentURLFromMarkdown: (markdown) ->
        html = @.getHTML(markdown)

        return @.refreshAttachmentURL(html).then (html) =>
            return @.getMarkdown(html)

    refreshAttachmentURL: (html) ->
        el = document.createElement('html')
        el.innerHTML = @sce.getTrustedHtml(html) || ''
        regex = /#_taiga-refresh=([a-zA-Z]*\:\d+)/

        links = {
            "elements": el.querySelectorAll('a'),
            "attr": "href",
        }
        images = {
            "elements": el.querySelectorAll('img'),
            "attr": "src",
        }

        promises = []
        _.map [links, images], (tag) =>
            _.map tag.elements, (e) =>
                if e.getAttribute(tag.attr) && e.getAttribute(tag.attr).indexOf('#_taiga-refresh=') != -1
                    match = e.getAttribute(tag.attr).match(regex)
                    if match && match.length == 2
                        tokens = match[1].split(":")

                        promise = @.getCachedAttachment(tokens)
                        .then (url) =>
                            e.setAttribute(tag.attr, url)
                        .catch () =>
                            console.warn('attachment ref not found', e.getAttribute(tag.attr))

                        promises.push(promise)

        Promise.all(promises).then ->
            return el.innerHTML

angular.module("taigaComponents")
    .service("tgWysiwygService", WysiwygService)
