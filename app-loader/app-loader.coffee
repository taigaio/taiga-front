window._version = "___VERSION___"

window.taigaConfig = {
    "api": "http://localhost:8000/api/v1/",
    "eventsUrl": null,
    "tribeHost": null,
    "eventsMaxMissedHeartbeats": 5,
    "eventsHeartbeatIntervalTime": 60000,
    "debug": true,
    "defaultLanguage": "en",
    "themes": ["taiga", "material-design", "high-contrast"],
    "defaultTheme": "taiga",
    "publicRegisterEnabled": true,
    "feedbackEnabled": true,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "importers": [],
    "contribPlugins": []
}

window.taigaContribPlugins = []

window._decorators = []

window.addDecorator = (provider, decorator) ->
    window._decorators.push({provider: provider, decorator: decorator})

window.getDecorators = ->
    return window._decorators

loadStylesheet = (path) ->
    $('head').append('<link rel="stylesheet" href="' + path + '" type="text/css" />')

loadPlugin = (pluginPath) ->
    return new Promise (resolve, reject) ->
        success = (plugin) ->
            if plugin.isPack
                for item in plugin.plugins
                    window.taigaContribPlugins.push(item)
            else
                window.taigaContribPlugins.push(plugin)

            if plugin.css
                loadStylesheet(plugin.css)

            #dont' wait for css
            if plugin.js
                ljs.load(plugin.js, resolve)
            else
                resolve()

        fail = (a, errorStr, e) ->
            console.error("error loading", pluginPath, e)

        $.getJSON(pluginPath).then(success, fail)

loadPlugins = (plugins) ->
    promises = []
    _.map plugins, (pluginPath) ->
        promises.push(loadPlugin(pluginPath))

    return Promise.all(promises)

promise = $.getJSON "/conf.json"
promise.done (data) ->
    window.taigaConfig = _.assign({}, window.taigaConfig, data)

promise.fail () ->
    console.error "Your conf.json file is not a valid json file, please review it."

promise.always ->
    if window.taigaConfig.contribPlugins.length > 0
        loadPlugins(window.taigaConfig.contribPlugins).then () ->
            ljs.load "/#{window._version}/js/app.js", ->
                angular.bootstrap(document, ['taiga'])
    else
        ljs.load "/#{window._version}/js/app.js", ->
            angular.bootstrap(document, ['taiga'])
