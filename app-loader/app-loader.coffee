version = ___VERSION___
window.taigaConfig = {
    "api": "http://localhost:8000/api/v1/",
    "eventsUrl": null,
    "debug": true,
    "defaultLanguage": "en",
    "themes": ["taiga"],
    "defaultTheme": "taiga",
    "publicRegisterEnabled": true,
    "feedbackEnabled": true,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "contribPlugins": []
}

promise = $.getJSON "/js/conf.json"
promise.done (data) ->
    window.taigaConfig = _.extend({}, window.taigaConfig, data)

promise.always ->
    if window.taigaConfig.contribPlugins.length > 0
        plugins = _.map(window.taigaConfig.contribPlugins, (plugin) -> "#{plugin}?v=#{version}")
        ljs.load plugins, ->
            ljs.load "/js/app.js?v=#{version}", ->
                angular.bootstrap(document, ['taiga'])
    else
        ljs.load "/js/app.js?v=#{version}", ->
            angular.bootstrap(document, ['taiga'])
