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
# File: services/app-meta.service.coffee
###

taiga = @.taiga

truncate = taiga.truncate


class AppMetaService
    @.$inject = [
        "$rootScope"
    ]

    constructor: (@rootScope) ->

    _set: (key, value) ->
        return if not key

        if key == "title"
            meta = $("head title")

            if meta.length == 0
                meta = $("<title></title>")
                $("head").append(meta)

            meta.text(value or "")
        else if key.indexOf("og:") == 0
            meta = $("head meta[property='#{key}']")

            if meta.length == 0
                meta = $("<meta property='#{key}'/>")
                $("head").append(meta)

            meta.attr("content", value or "")
        else
            meta = $("head meta[name='#{key}']")

            if meta.length == 0
                meta = $("<meta name='#{key}'/>")
                $("head").append(meta)

            meta.attr("content", value or "")

    setTitle: (title) ->
        @._set('title', title)

    setDescription: (description) ->
        @._set("description", truncate(description, 250))

    setTwitterMetas: (title, description) ->
        @._set("twitter:card", "summary")
        @._set("twitter:site", "@taigaio")
        @._set("twitter:title", title)
        @._set("twitter:description", truncate(description, 300))
        @._set("twitter:image", "#{window.location.origin}/#{window._version}/images/logo-color.png")

    setOpenGraphMetas: (title, description) ->
        @._set("og:type", "object")
        @._set("og:site_name", "Taiga - Love your projects")
        @._set("og:title", title)
        @._set("og:description", truncate(description, 300))
        @._set("og:image", "#{window.location.origin}/#{window._version}/images/logo-color.png")
        @._set("og:url", window.location.href)

    setAll: (title, description) ->
        @.setTitle(title)
        @.setDescription(description)
        @.setTwitterMetas(title, description)
        @.setOpenGraphMetas(title, description)

    addMobileViewport: () ->
        $("head").append(
            "<meta name=\"viewport\"
                   content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\">"
        )

    removeMobileViewport: () ->
        $("head meta[name=\"viewport\"]").remove()

    setfn: (fn) ->
        @._listener() if @.listener

        @._listener = @rootScope.$watchCollection fn, (metas) =>
            if metas
                @.setAll(metas.title, metas.description)
                @._listener()

angular.module("taigaCommon").service("tgAppMetaService", AppMetaService)
