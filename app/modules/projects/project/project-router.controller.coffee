###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: project-router.controller.coffee
###

class ProjectRouterController
    @.$inject = [
        "$routeParams",
        "$location"
        "tgProjectService"
        "$tgResources"
        "$tgSections"
    ]

    constructor: (@routeParams, @location, @projectService, @rs, @tgSections) ->
        @getProjectHomepage()
            .then (section) =>
                if section
                    @location.url("project/#{@routeParams.pslug}/#{section}")
                else
                    @gotoDefaultProjectHomepage()
            .then null, ->
                @gotoDefaultProjectHomepage()

    gotoDefaultProjectHomepage: () ->
        @location.url("project/#{@routeParams.pslug}/timeline")

    getProjectHomepage: () ->
        project = @projectService.project.toJS()

        @rs.userProjectSettings.list({project: project.id}).then (userProjectSettings) =>
            settings = _.find(userProjectSettings, {"project": project.id})
            return if !settings

            return @tgSections.getPath(project.slug, settings.homepage)

angular.module("taigaProjects").controller("ProjectRouter", ProjectRouterController)
