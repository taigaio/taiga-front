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
# File: modules/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
bindMethods = @.taiga.bindMethods

module = angular.module("taigaCommon")

class DetailController
    @.$inject = [
        '$routeParams',
        '$tgRepo',
        "tgProjectService",
        "$tgNavUrls",
        "$location"
    ]

    constructor: (@params, @repo, @projectService, @navurls, @location) ->
        @repo.resolve({
            pslug: @params.pslug,
            ref: @params.ref
        })
        .then (result) =>
            if result.issue
                url = @navurls.resolve('project-issues-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.task
                url = @navurls.resolve('project-tasks-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.us
                url = @navurls.resolve('project-userstories-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.epic
                url = @navurls.resolve('project-epics-detail', {
                    project: @projectService.project.get('slug'),
                    ref: @params.ref
                })
            else if result.wikipage
                url = @navurls.resolve('project-wiki-page', {
                    project: @projectService.project.get('slug'),
                    slug: @params.ref
                })

            @location.path(url)

module.controller("DetailController", DetailController)
