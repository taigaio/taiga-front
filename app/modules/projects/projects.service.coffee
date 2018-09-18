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
# File: projects/projects.service.coffee
###

taiga = @.taiga
groupBy = @.taiga.groupBy


class ProjectsService extends taiga.Service
    @.$inject = ["tgResources", "$projectUrl"]

    constructor: (@rs, @projectUrl) ->

    create: (data) ->
        return @rs.projects.create(data)

    duplicate: (projectId, data) ->
        return @rs.projects.duplicate(projectId, data)

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

        return project

    bulkUpdateProjectsOrder: (sortData) ->
        return @rs.projects.bulkUpdateOrder(sortData)

    transferValidateToken: (projectId, token) ->
        return @rs.projects.transferValidateToken(projectId, token)

    transferAccept: (projectId, token, reason) ->
        return @rs.projects.transferAccept(projectId, token, reason)

    transferReject: (projectId, token, reason) ->
        return @rs.projects.transferReject(projectId, token, reason)


angular.module("taigaProjects").service("tgProjectsService", ProjectsService)
