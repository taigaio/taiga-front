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
    ]

    constructor: (@navUrls) ->
        return

    _checkNav: () ->
        if @.item.neighbors.previous?.ref?
            ctx = {
                project: @.item.project_extra_info.slug
                ref: @.item.neighbors.previous.ref
            }
            @.previousUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

        if @.item.neighbors.next?.ref?
            ctx = {
                project: @.item.project_extra_info.slug
                ref: @.item.neighbors.next.ref
            }
            @.nextUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

module.controller("DetailNavCtrl", DetailNavController)
