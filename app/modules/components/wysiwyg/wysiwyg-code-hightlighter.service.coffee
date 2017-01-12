###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/components/wysiwyg/wysiwyg-code-hightlighter.service.coffee
###

class WysiwygCodeHightlighterService
    constructor: () ->
        if !@.languages
            @.loadLanguages()

    loadLanguages: () ->
        $.getJSON("/#{window._version}/prism/prism-languages.json").then (_languages_) =>
            @.languages = _.map _languages_, (it) ->
                it.url = "/#{window._version}/prism/" + it.file

                return it

    getLanguageInClassList: (classes) ->
        lan = _.find @.languages, (it) ->
            return !!_.find classes, (className) ->
                return 'language-' + it.name == className

        return if lan then lan.name else null

    addCodeLanguageSelectors: (mediumInstance) ->
        $(mediumInstance.elements[0]).find('code').each (index, code) =>
            if !code.classList.contains('has-code-lan-selector')
                code.classList.add('has-code-lan-selector') # prevent multi instanciate

                currentLan = @.getLanguageInClassList(code.classList)

                id = new Date().getTime()

                text = document.createTextNode(currentLan || 'text')

                tab = document.createElement('div')
                tab.appendChild(text)
                tab.addEventListener 'click', () =>
                    @.searchLanguage tab, (lan) =>
                        if lan
                            tab.innerText = lan
                            @.updatePositionCodeTab(code.parentElement, tab)

                            languageClass = _.find code.classList, (className) ->
                                return className && className.indexOf('language-') != -1

                            code.classList.remove(languageClass.replace('language-', ''))
                            code.classList.remove(languageClass)

                            code.classList.add('language-' + lan)
                            code.classList.add(lan)

                document.body.appendChild(tab)

                code.dataset.tab = tab


                if !code.dataset.tabId
                    code.dataset.tabId = id
                    code.classList.add(id)

                tab.dataset.tabId = code.dataset.tabId

                tab.classList.add('code-language-selector') # styles
                tab.classList.add('medium-' + mediumInstance.id) # used to delete

                @.updatePositionCodeTab(code.parentElement, tab)

    removeCodeLanguageSelectors: (mediumInstance) ->
        return if !mediumInstance || !mediumInstance.elements

        $(mediumInstance.elements[0]).find('code').each (index, code) ->
            $(code).removeClass('has-code-lan-selector')

        $('.medium-' + mediumInstance.id).remove()

    updatePositionCodeTab: (node, tab) ->
        preRects = node.getBoundingClientRect()

        tab.style.top = (preRects.top + $(window).scrollTop()) + 'px'
        tab.style.left = (preRects.left + preRects.width - tab.offsetWidth) + 'px'

    getCodeLanHTML: (filter = '') ->
        template = _.template("""
        <% _.forEach(lans, function(lan) { %>
          <li><%- lan %></li><% });
        %>
        """);

        filteresLans = _.map @.languages, (it) -> it.name

        if filter.length
            filteresLans = _.filter filteresLans, (it) ->
                return it.indexOf(filter) != -1

        return template({ 'lans': filteresLans });

    searchLanguage: (tab, cb) ->
        search = document.createElement('div')

        search.className = 'code-language-search'

        preRects = tab.getBoundingClientRect()
        search.style.top = (preRects.top + $(window).scrollTop() + preRects.height) + 'px'
        search.style.left = preRects.left + 'px'

        input = document.createElement('input')
        input.setAttribute('type', 'text')

        ul = document.createElement('ul')

        ul.innerHTML = @.getCodeLanHTML()

        search.appendChild(input)
        search.appendChild(ul)

        document.body.appendChild(search)

        input.focus()

        close = () ->
            search.remove()
            $(document.body).off('.leave-search-codelan')

        clickedInSearchBox = (target) ->
            return $(search).is(target) || !!$(search).has(target).length

        $(document.body).on 'mouseup.leave-search-codelan', (e) ->
            if !clickedInSearchBox(e.target)
                cb(null)
                close()

        $(input).on 'keyup', (e) =>
            filter = e.currentTarget.value
            ul.innerHTML = @.getCodeLanHTML(filter)

        $(ul).on 'click', 'li', (e) ->
            cb(e.currentTarget.innerText)
            close()

    loadLanguage: (lan) ->
        return new Promise (resolve) ->
            if !Prism.languages[lan]
                ljs.load("/#{window._version}/prism/prism-#{lan}.min.js", resolve)
            else
                resolve()

    removeHightlighter: (element) ->
        codes = $(element).find('code')

        codes.each (index, code) ->
            code.innerHTML = code.innerText

    # firefox adds br instead of new lines inside <code>
    replaceCodeBrToNl: (code) ->
        $(code).find('br').replaceWith('\n')

    addHightlighter: (element) ->
        codes = $(element).find('code')

        codes.each (index, code) =>
            @.replaceCodeBrToNl(code)

            lan = @.getLanguageInClassList(code.classList)

            if lan
                @.loadLanguage(lan).then () -> Prism.highlightElement(code)

    updateCodeLanguageSelector: (mediumInstance) ->
        $('.medium-' + mediumInstance.id).each (index, tab) =>
            node = $('.' + tab.dataset.tabId)

            if !node.length
                tab.remove()
            else
                @.updatePositionCodeTab(node.parent()[0], tab)

angular.module("taigaComponents")
    .service("tgWysiwygCodeHightlighterService", WysiwygCodeHightlighterService)
