###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProfileTabsController
    constructor: () ->
        @tabs = []

    addTab: (tab) ->
        @tabs.push(tab)

    toggleTab: (tab) ->
        _.map @tabs, (tab) -> tab.active = false

        tab.active = true

angular.module("taigaProfile")
    .controller("ProfileTabs", ProfileTabsController)
