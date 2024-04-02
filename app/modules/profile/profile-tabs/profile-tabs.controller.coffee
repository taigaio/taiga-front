###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
