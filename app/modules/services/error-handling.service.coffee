taiga = @.taiga

class ErrorHandlingService
    @.$inject = [
        "$rootScope"
    ]

    constructor: (@rootScope) ->

    init: () ->
        @rootScope.errorHandling = {}

    notfound: ->
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.notfound = true

    error: ->
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.error = true

    permissionDenied: ->
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.permissionDenied = true

    block: ->
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.blocked = true

angular.module("taigaCommon").service("tgErrorHandlingService", ErrorHandlingService)
