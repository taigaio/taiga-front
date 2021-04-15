###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class xhrError extends taiga.Service
    @.$inject = [
        "$q",
        "tgErrorHandlingService"
    ]

    constructor: (@q, @errorHandlingService) ->

    notFound: () ->
        @errorHandlingService.notfound()

    permissionDenied: () ->
        @errorHandlingService.permissionDenied()

    response: (xhr) ->
        if xhr
            if xhr.status == 404
                @.notFound()

            else if xhr.status == 403
                @.permissionDenied()

        return @q.reject(xhr)

angular.module("taigaCommon").service("tgXhrErrorService", xhrError)
