class NavigationBarService extends taiga.Service

    constructor: ->
        @.disableHeader()

    enableHeader: ->
        @.enabledHeader = true

    disableHeader:  ->
        @.enabledHeader = false

    isEnabledHeader: ->
        return @.enabledHeader

angular.module("taigaNavigationBar").service("tgNavigationBarService", NavigationBarService)
