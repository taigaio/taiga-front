###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class ProfileBarController
    @.$inject = [
        "tgUserService"
    ]

    constructor: (@userService) ->
        @.loadStats()

    loadStats: () ->
        return @userService.getStats(@.user.get("id")).then (stats) =>
            @.stats = stats

angular.module("taigaProfile").controller("ProfileBar", ProfileBarController)
