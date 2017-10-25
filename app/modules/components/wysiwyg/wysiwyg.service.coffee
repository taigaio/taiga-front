###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/components/wysiwyg/wysiwyg.service.coffee
###

class WysiwygService
    @.$inject = [
        "tgWysiwygCodeHightlighterService",
        "tgProjectService",
        "$tgNavUrls",
        "$tgEmojis"
    ]
    constructor: (@wysiwygCodeHightlighterService, @projectService, @navurls, @emojis) ->

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
                link.parentNode.replaceChild(document.createTextNode(link.innerText), link)
            else if link.getAttribute('href').indexOf('/t/') != -1
                link.parentNode.replaceChild(document.createTextNode(link.innerText), link)

        return el.innerHTML

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
            filter:  (node) =>
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

                    return '<a class="autolink" href="' + profileUrl + '">@' + match.getMention() + '</a>'
                else if match.getType() == 'hashtag'
                    url = @navurls.resolve('project-detail-ref', {
                        project: @projectService.project.get('slug'),
                        ref: match.getHashtag()
                    })

                    return '<a class="autolink" href="' + url + '">#' + match.getHashtag() + '</a>'
        })

        Autolinker.matcher.Mention.prototype.parseMatches = @.parseMentionMatches.bind(autolinker)

        return autolinker.link(html);

    getHTML: (text) ->
        return "" if !text || !text.length

        options = {
            breaks: true
        }

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
