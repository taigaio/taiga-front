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
