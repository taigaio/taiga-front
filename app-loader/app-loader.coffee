window._version = "___VERSION___"
window.taigaConfig = {
    "api": "http://localhost:8000/api/v1/",
    "eventsUrl": null,
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
    "contribPlugins": []
}

promise = $.getJSON "/conf.json"
promise.done (data) ->
    window.taigaConfig = _.extend({}, window.taigaConfig, data)

promise.always ->
    if window.taigaConfig.contribPlugins.length > 0
        plugins = _.map(window.taigaConfig.contribPlugins, (plugin) -> "#{plugin}")
        ljs.load plugins, ->
            ljs.load "/#{window._version}/js/app.js", ->
                angular.bootstrap(document, ['taiga'])
    else
        ljs.load "/#{window._version}/js/app.js", ->
            angular.bootstrap(document, ['taiga'])
