###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaHistory")

class ActivitiesDiffController
    @.$inject = [
    ]

    constructor: () ->

    diffTags: () ->
        if @.type == 'tags'
            @.diffRemoveTags = _.difference(@.diff[0], @.diff[1]).toString()
            @.diffAddTags = _.difference(@.diff[1], @.diff[0]).toString()
        else if @.type == 'promoted_to'
            diff = _.difference(@.diff[1], @.diff[0])
            @.promotedTo = _.filter(@.model.generated_user_stories, (x) => _.includes(diff, x.id))

module.controller("ActivitiesDiffCtrl", ActivitiesDiffController)
