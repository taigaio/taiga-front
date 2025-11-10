###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class ErrorHandlingService
    @.$inject = [
        "$rootScope",
        "$window",
        "$location"
    ]

    constructor: (@rootScope, @window, @location) ->
        @.errorHistory = []
        @.maxHistorySize = 20

    init: () ->
        @rootScope.errorHandling = {}

    notfound: (context) ->
        @._recordError("not_found", context)
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.notfound = true

    error: (context) ->
        @._recordError("error", context)
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.error = true

    permissionDenied: (context) ->
        @._recordError("permission_denied", context)
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.permissionDenied = true

    block: (context) ->
        @._recordError("blocked", context)
        @rootScope.errorHandling.showingError = true
        @rootScope.errorHandling.blocked = true

    _recordError: (type, context) ->
        errorInfo = {
            type: type
            timestamp: Date.now()
            url: @location.absUrl()
            path: @location.path()
            userAgent: @window.navigator.userAgent
            context: context
        }

        @.errorHistory.push(errorInfo)

        if @.errorHistory.length > @.maxHistorySize
            @.errorHistory.shift()

    getErrorHistory: ->
        return @.errorHistory.slice()

    clearErrorHistory: ->
        @.errorHistory = []

angular.module("taigaCommon").service("tgErrorHandlingService", ErrorHandlingService)
