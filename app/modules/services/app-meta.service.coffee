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
            meta = $("title")

            if meta.length == 0
                meta = $("<title></title>")
                $("head").append(meta)

            meta.text(value or "")
        else if key.indexOf("og:") == 0
            meta = $("meta[property='#{key}']")

            if meta.length == 0
                meta = $("<meta property='#{key}'/>")
                $("head").append(meta)

            meta.attr("content", value or "")
        else
            meta = $("meta[name='#{key}']")

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
        @._set("twitter:image", "#{window.location.origin}/images/logo-color.png")

    setOpenGraphMetas: (title, description) ->
        @._set("og:type", "object")
        @._set("og:site_name", "Taiga - Love your projects")
        @._set("og:title", title)
        @._set("og:description", truncate(description, 300))
        @._set("og:image", "#{window.location.origin}/images/logo-color.png")
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
        $("meta[name=\"viewport\"]").remove()

    setfn: (fn) ->
        @._listener() if @.listener

        @._listener = @rootScope.$watchCollection fn, (metas) =>
            @.setAll(metas.title, metas.description)


angular.module("taigaCommon").service("tgAppMetaService", AppMetaService)
