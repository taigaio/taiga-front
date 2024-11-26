###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
