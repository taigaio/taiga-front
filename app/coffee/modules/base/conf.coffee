class ConfigurationService
    constructor: () ->
        @.config = window.taigaConfig

    get: (key, defaultValue=null) ->
        if _.has(@.config, key)
            return @.config[key]
        return defaultValue


module = angular.module("taigaBase")
module.service("$tgConfig", ConfigurationService)
