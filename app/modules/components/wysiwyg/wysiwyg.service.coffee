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
# File: components/wysiwyg/wysiwyg.service.coffee
###

class WysiwygService
    @.$inject = [
        "tgWysiwygCodeHightlighterService",
        "tgProjectService",
        "$tgNavUrls",
        "$tgEmojis",
        "tgAttachmentsService",
        "$q",
    ]
    constructor: (@wysiwygCodeHightlighterService, @projectService, @navurls, @emojis, @attachmentsService, @q) ->
        @.members = @projectService.project.get('members').toJS()  # Array of User objects
        @.memberObjectMap = {}
        for m in @.members
            @.memberObjectMap[m.username] = m

    searchEmojiByName: (name) ->
        return @emojis.searchByName(name)

    pipeLinks: (text) ->
        return text.replace /\[\[(.*?)\]\]/g, (match, p1, offset, str) ->
            linkParams = p1.split('|')

            link = linkParams[0]
            title = linkParams[1] || linkParams[0]

            return '[' + title + '](' + link  + ')'

    replaceUrls: (html) ->
        el = document.createElement( 'html' )
        el.innerHTML = html

        links = el.querySelectorAll('a')

        for link in links
            if link.getAttribute('href').indexOf('/profile/') != -1
                # https://github.com/taigaio/taiga-front/issues/1859 (Show full name in user mentions autocompletion)
                username = link.getAttribute('href').split('/profile/')[1]  # Override username <-> full_name
                link.innerText = '@' + username
                link.parentNode.replaceChild(document.createTextNode(link.innerText), link)
            else if link.getAttribute('href').indexOf('/t/') != -1
                link.parentNode.replaceChild(document.createTextNode(link.innerText), link)

        return el.innerHTML

    getAttachmentData: (el, tokens, attr) ->
        deferred = @q.defer()
        @attachmentsService.get(tokens[0], tokens[1]).then (response) ->
            el.setAttribute(attr, "#{response.data.url}#_taiga-refresh=#{tokens[0]}:#{tokens[1]}")
            deferred.resolve(el)

        return deferred.promise

    refreshAttachmentURL: (html) ->
        el = document.createElement( 'html' )
        el.innerHTML = html
        regex = /#_taiga-refresh=([a-zA-Z]*\:\d+)/

        links = {
            "elements": el.querySelectorAll('a'),
            "attr": "href",
        }
        images = {
            "elements": el.querySelectorAll('img'),
            "attr": "src",
        }

        deferred = @q.defer()
        promises = []
        _.map [links, images], (tag) =>
            _.map tag.elements, (e) =>
                if e.getAttribute(tag.attr).indexOf('#_taiga-refresh=') != -1
                    match = e.getAttribute(tag.attr).match(regex)
                    if match
                        tokens = match[1].split(":")
                        promises.push(@.getAttachmentData(e, tokens, tag.attr))

        @q.all(promises).then ->
            deferred.resolve(el.innerHTML)

        return deferred.promise

    searchWikiLinks: (html) ->
        el = document.createElement( 'html' )
        el.innerHTML = html

        links = el.querySelectorAll('a')

        for link in links
            if link.getAttribute('href').indexOf('/') == -1
                url = @navurls.resolve('project-wiki-page', {
                    project: @projectService.project.get('slug'),
                    slug: link.getAttribute('href')
                })

                link.setAttribute('href', url)

        return el.innerHTML

    removeTrailingListBr: (text) ->
        return text.replace(/<li>(.*?)<br><\/li>/g, '<li>$1</li>')

    getMarkdown: (html) ->
        # https://github.com/yabwe/medium-editor/issues/543
        cleanIssueConverter = {
            filter: ['html', 'body', 'span', 'div'],
            replacement: (innerHTML) ->
                return innerHTML
        }

        codeLanguageConverter = {
            filter:  (node) ->
                return node.nodeName == 'PRE' &&
                  node.firstChild &&
                  node.firstChild.nodeName == 'CODE'
            replacement: (content, node) =>
                lan = @wysiwygCodeHightlighterService.getLanguageInClassList(node.firstChild.classList)
                lan = '' if !lan

                return '\n\n```' + lan + '\n' + _.trim(node.firstChild.textContent) + '\n```\n\n'
         }

        html = html.replace(/&nbsp;(<\/.*>)/g, "$1")
        html = @emojis.replaceImgsByEmojiName(html)
        html = @.replaceUrls(html)
        html = @.removeTrailingListBr(html)

        markdown = toMarkdown(html, {
            gfm: true,
            converters: [cleanIssueConverter, codeLanguageConverter]
        })

        return markdown

    parseMentionMatches: (text) ->
        serviceName = 'twitter'
        tagBuilder = this.tagBuilder
        matches = []

        regex = /@[^\s]{1,50}[^.\s]/g
        m = regex.exec(text)

        while m != null
            offset = m.index
            prevChar = text.charAt( offset - 1 )

            if m.index == regex.lastIndex
                regex.lastIndex++

            m.forEach (match, groupIndex) ->
                matches.push( new Autolinker.match.Mention({
                    tagBuilder    : tagBuilder,
                    matchedText   : match,
                    offset        : offset,
                    serviceName   : serviceName,
                    mention       : match.slice(1)
                }))

            m = regex.exec(text)

        return matches

    escapeEmojisInUrls: (text) ->
        urls = taiga.getMatches(
            text,
            /[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/g
        )

        for url in urls
            emojiIds = taiga.getMatches(url, /:([\w +-]*):/g)
            for emojiId in emojiIds
                escapedUrl = url.replace(":#{emojiId}:", "\\:#{emojiId}\\:")
                text = text.replace(url, escapedUrl)

        return text

    autoLinkHTML: (html) ->
        # override Autolink parser

        matchRegexStr = String(Autolinker.matcher.Mention.prototype.matcherRegexes.twitter)
        if matchRegexStr.indexOf('.') == -1
            matchRegexStr = '@[^\s]{1,50}[^.\s]'

        autolinker = new Autolinker({
            mention: 'twitter',
            hashtag: 'twitter',
            replaceFn: (match) =>
                if  match.getType() == 'mention'
                    profileUrl = @navurls.resolve('user-profile', {
                        project: @projectService.project.get('slug'),
                        username: match.getMention()
                    })
                    if @.memberObjectMap.hasOwnProperty(match.getMention())
                        member = @.memberObjectMap[match.getMention()]
                        if member.full_name
                            return '<a class="autolink" href="' + profileUrl + '">@' + member.full_name + '</a>'
                    else
                        return '<a class="autolink" href="' + profileUrl + '">@' + match.getMention() + '</a>'

                else if match.getType() == 'hashtag'
                    url = @navurls.resolve('project-detail-ref', {
                        project: @projectService.project.get('slug'),
                        ref: match.getHashtag()
                    })

                    return '<a class="autolink" href="' + url + '">#' + match.getHashtag() + '</a>'
        })

        Autolinker.matcher.Mention.prototype.parseMatches = @.parseMentionMatches.bind(autolinker)

        return autolinker.link(html)

    getHTML: (text) ->
        return "" if !text || !text.length

        options = {
            breaks: true
        }

        text = @.escapeEmojisInUrls(text)
        text = @emojis.replaceEmojiNameByImgs(text)
        text = @.pipeLinks(text)

        md = window.markdownit({
            breaks: true
        })

        md.use(window.markdownitLazyHeaders)
        result = md.render(text)
        result = @.searchWikiLinks(result)
        result = @.autoLinkHTML(result)

        return result

angular.module("taigaComponents")
    .service("tgWysiwygService", WysiwygService)
