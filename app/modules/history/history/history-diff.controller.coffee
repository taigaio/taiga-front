###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
