###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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

        window._extraValidHtmlElments = {input: true}
        window._extraValidAttrs = {checked: true}

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
