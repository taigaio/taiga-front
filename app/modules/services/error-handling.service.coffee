###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

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
