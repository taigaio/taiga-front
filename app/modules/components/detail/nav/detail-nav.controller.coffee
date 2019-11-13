###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: components/detail/nav/detail-nav.controller.coffee
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
