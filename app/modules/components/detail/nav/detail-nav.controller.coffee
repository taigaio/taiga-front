###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaBase")

class DetailNavController
    @.$inject = [
        "$tgNavUrls",
        "$tgResources",
    ]

    constructor: (@navUrls, @rs) ->
        return

    _checkNav: () ->
        params = @rs.userstories.getQueryParams(@.item.project_extra_info.id)
        noMilestone = params.milestone == 'null'

        neighbors = @.item.neighbors

        @.previousUrl = null
        @.nextUrl = null

        if noMilestone
            uss = @rs.userstories.getBacklog(@.item.project_extra_info.id)
            index = uss.findIndex (ref) => ref == @.item.ref

            if index != -1
                neighbors = {
                    previous: {
                        ref: uss[index - 1]
                    },
                    next: {
                        ref: uss[index + 1]
                    },
                }

        if neighbors.previous?.ref?
            ctx = {
                project: @.item.project_extra_info.slug
                ref: neighbors.previous.ref
            }
            @.previousUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

        if neighbors.next?.ref?
            ctx = {
                project: @.item.project_extra_info.slug
                ref: neighbors.next.ref
            }
            @.nextUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

module.controller("DetailNavCtrl", DetailNavController)
