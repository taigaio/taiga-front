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
# File: components/wysiwyg/wysiwyg-code-hightlighter.service.coffee
###

class WysiwygCodeHightlighterService
    constructor: () ->
        Prism.plugins.customClass.prefix('prism-')
        Prism.plugins.customClass.map({})        
        
    getLanguages: () ->
        return new Promise (resolve, reject) =>
            if @.languages
                resolve(@.languages)
            else if @.loadPromise
                @.loadPromise.then () => resolve(@.languages)
            else
                @.loadPromise = $.getJSON("/#{window._version}/prism/prism-languages.json").then (_languages_) =>
                    @.loadPromise = null
                    @.languages = _.map _languages_, (it) ->
                        it.url = "/#{window._version}/prism/" + it.file

                        return it

                    resolve(@.languages)

    getLanguageInClassList: (classes) ->
        lan = _.find @.languages, (it) ->
            return !!_.find classes, (className) ->
                return 'language-' + it.name == className

        return if lan then lan.name else null

    loadLanguage: (lan) ->
        return new Promise (resolve) ->
            if !Prism.languages[lan]
                ljs.load("/#{window._version}/prism/prism-#{lan}.min.js", resolve)
            else
                resolve()

    # firefox adds br instead of new lines inside <code>
    replaceCodeBrToNl: (code) ->
        $(code).find('br').replaceWith('\n')

     hightlightCode: (code) ->
        @.replaceCodeBrToNl(code)

        lan = @.getLanguageInClassList(code.classList)

        if lan
            @.loadLanguage(lan).then () -> Prism.highlightElement(code)

    addHightlighter: (element) ->
        codes = $(element).find('code')

        codes.each (index, code) => @.hightlightCode(code)

angular.module("taigaComponents")
    .service("tgWysiwygCodeHightlighterService", WysiwygCodeHightlighterService)
