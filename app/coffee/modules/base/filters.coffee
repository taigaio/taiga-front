taiga = @.taiga

class FiltersStorageService extends taiga.Service
    @.$inject = ["$tgStorage", "$routeParams"]

    constructor: (@storage, @params) ->

    generateHash: (components=[]) ->
        components = _.map(components, (x) -> JSON.stringify(x))
        return hex_sha1(components.join(":"))
