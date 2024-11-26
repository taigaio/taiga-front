###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

window._version = "___VERSION___"

window.taigaConfig = {
    "api": "http://localhost:8000/api/v1/",
    "newsletterSubscriberUrl": "https://newsletter-subscriber.taiga.io",
    "eventsUrl": null,
    "tribeHost": null,
    "eventsMaxMissedHeartbeats": 5,
    "eventsHeartbeatIntervalTime": 60000,
    "debug": false,
    "defaultLanguage": "en",
    "themes": ["taiga", "taiga-legacy", "material-design", "high-contrast"],
    "defaultTheme": "taiga",
    "publicRegisterEnabled": true,
    "feedbackEnabled": true,
    "supportUrl": null,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "enableAsanaImporter": false,
    "enableGithubImporter": false,
    "enableJiraImporter": false,
    "enableTrelloImporter": false,
    "contribPlugins": [],
    "baseHref": "/"
}

window.taigaContribPlugins = []

window._decorators = []

window.addDecorator = (provider, decorator) ->
    window._decorators.push({provider: provider, decorator: decorator})

window.getDecorators = ->
    return window._decorators

loadStylesheet = (path) ->
    link = document.createElement('link')
    link.href = path
    link.type = 'text/css'
    link.rel = 'stylesheet'
    document.getElementsByTagName('head')[0].appendChild(link)

loadJS = (path) ->
    return new Promise (resolve, reject) ->
        script = document.createElement('script')
        script.type = 'text/javascript'
        script.src = path
        script.onload = resolve
        script.onerror = (err) ->
            reject(err, s)
        document.body.appendChild(script)

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
                loadJS(plugin.js).then(resolve)
            else
                resolve()

        fail = (jqXHR, textStatus, errorThrown) ->
            console.error("Error loading plugin", pluginPath, errorThrown)

        fetch(pluginPath)
        .then((response) => response.json())
        .then(success, fail)

loadPlugins = (plugins) ->
    promises = []
    plugins.forEach (pluginPath) ->
        promises.push(loadPlugin(pluginPath))

    return Promise.all(promises)

mainLoad = ->
    emojisPromise = fetch("#{window._version}/emojis/emojis-data.json")
    .then((response) => response.json())
    .then (emojis) ->
        window.emojis = emojis
    if window.taigaConfig.contribPlugins.length > 0
        loadJS("#{window._version}/js/libs.js")
            .then(() => loadJS("#{window._version}/js/templates.js"))
            .then(() => loadPlugins(window.taigaConfig.contribPlugins))
            .then(() => loadApp(emojisPromise))
    else
        loadJS("#{window._version}/js/libs.js")
            .then(() => loadJS("#{window._version}/js/templates.js"))
            .then(() => loadApp(emojisPromise))

loadApp = (emojisPromise) ->
    loadJS("#{window._version}/js/elements.js").then () ->
        loadJS("#{window._version}/js/app.js").then () ->
            emojisPromise.then ->
                angular.bootstrap(document, ['taiga'])

promise = fetch "conf.json"
promise
.then((response) => response.json())
.then (data) ->
    window.taigaConfig = Object.assign({}, window.taigaConfig, data)

    base = document.querySelector('base')

    if base && window.taigaConfig.baseHref
        base.setAttribute("href", window.taigaConfig.baseHref)
    else if !base && window.taigaConfig.baseHref
        base = document.createElement('base')
        base.setAttribute("href", window.taigaConfig.baseHref)
        document.head.appendChild(base)

    mainLoad()

promise.catch () ->
    console.error "Your conf.json file is not a valid json file, please review it."
    mainLoad()
