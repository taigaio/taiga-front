taiga = @.taiga

class StorageService extends taiga.Service
    @.$inject = ["$rootScope"]

    constructor: ($rootScope) ->
        super()

    get: (key, _default) ->
        serializedValue = localStorage.getItem(key)
        if serializedValue == null
            return _default or null

        return JSON.parse(serializedValue)

    set: (key, val) ->
        if _.isObject(key)
            _.each key, (val, key) =>
                @set(key, val)
        else
            localStorage.setItem(key, JSON.stringify(val))

    contains: (key) ->
        value = @.get(key)
        return (value != null)

    remove: (key) ->
        localStorage.removeItem(key)

    clear: ->
        localStorage.clear()


module = angular.module("taigaBase")
module.service("$tgStorage", StorageService)
