###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
