###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: xhrError.service.coffee
###

class xhrError extends taiga.Service
    @.$inject = [
        "$q",
        "$location",
        "$tgNavUrls"
    ]

    constructor: (@q, @location, @navUrls) ->

    notFound: () ->
        @location.path(@navUrls.resolve("not-found"))
        @location.replace()

    permissionDenied: () ->
        @location.path(@navUrls.resolve("permission-denied"))
        @location.replace()

    response: (xhr) ->
        if xhr
            if xhr.status == 404
                @.notFound()

            else if xhr.status == 403
                @.permissionDenied()

        return @q.reject(xhr)

angular.module("taigaCommon").service("tgXhrErrorService", xhrError)
