version = ___VERSION___
window.taigaConfig = {
    "api": "http://localhost:8000/api/v1/",
    "eventsUrl": null,
    "debug": true,
    "defaultLanguage": "en",
    "publicRegisterEnabled": true,
    "feedbackEnabled": true,
    "privacyPolicyUrl": null,
    "termsOfServiceUrl": null,
    "maxUploadFileSize": null,
    "dbAppKey": "",
    "contribPlugins": []
}

promise = $.getJSON "/js/conf.json"
promise.done (data) ->
    window.taigaConfig = _.extend({}, window.taigaConfig, data)
    dropin = document.createElement('script')
    dropin.src = 'https://www.dropbox.com/static/api/2/dropins.js'
    dropin.id = 'dropboxjs'
    dropin.setAttribute('data-app-key', window.taigaConfig.dbAppKey)
    document.getElementsByTagName('head')[0].appendChild(dropin)

promise.always ->
    if window.taigaConfig.contribPlugins.length > 0
        plugins = _.map(window.taigaConfig.contribPlugins, (plugin) -> "#{plugin}?v=#{version}")
        ljs.load plugins, ->
            ljs.load "/js/app.js?v=#{version}", ->
                angular.bootstrap(document, ['taiga'])
    else
        ljs.load "/js/app.js?v=#{version}", ->
            angular.bootstrap(document, ['taiga'])
