###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: projects.service.coffee
###

taiga = @.taiga
groupBy = @.taiga.groupBy

class ProjectsService extends taiga.Service
    @.$inject = ["tgResources", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @projectUrl, @lightboxFactory) ->

    getProjectBySlug: (projectSlug) ->
        return @rs.projects.getProjectBySlug(projectSlug)
            .then (project) =>
                return @._decorate(project)

    getProjectStats: (projectId) ->
        return @rs.projects.getProjectStats(projectId)

    getProjectsByUserId: (userId, paginate) ->
        return @rs.projects.getProjectsByUserId(userId, paginate)
            .then (projects) =>
                return projects.map @._decorate.bind(@)

    _decorate: (project) ->
        url = @projectUrl.get(project.toJS())

        project = project.set("url", url)
        colorized_tags = []

        if project.get("tags")
            tags = project.get("tags").sort()

            colorized_tags = tags.map (tag) ->
                color = project.get("tags_colors").get(tag)
                return Immutable.fromJS({name: tag, color: color})

            project = project.set("colorized_tags", colorized_tags)

        return project

    newProject: ->
        @lightboxFactory.create("tg-lb-create-project", {
            "class": "wizard-create-project lightbox"
        })

    bulkUpdateProjectsOrder: (sortData) ->
        return @rs.projects.bulkUpdateOrder(sortData)

angular.module("taigaProjects").service("tgProjectsService", ProjectsService)
