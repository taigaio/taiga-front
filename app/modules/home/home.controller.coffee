###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class HomeController
    @.$inject = [
        "tgCurrentUserService",
        "$location",
        "$tgNavUrls"
    ]

    constructor: (@currentUserService, @location, @navUrls) ->
        if not @currentUserService.getUser()
            @location.path(@navUrls.resolve("discover"))


angular.module("taigaHome").controller("Home", HomeController)
