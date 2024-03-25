###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
