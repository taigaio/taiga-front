module = angular.module('taigaCommon')

class TagLineService extends taiga.Service
    @.$inject = []

    constructor: () ->

    checkPermissions: (myPermissions, projectPermissions) ->
        return _.includes(myPermissions, projectPermissions)

    createColorsArray: (projectTagColors) ->
        return _.map(projectTagColors, (index, value) ->
            return [value, index]
        )

module.service("tgTagLineService", TagLineService)
