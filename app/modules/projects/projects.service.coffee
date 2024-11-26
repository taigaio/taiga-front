###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

    getListProjectsByUserId: (userId, paginate) ->
        return @rs.projects.getListProjectsByUserId(userId, paginate)
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
