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
# File: projects/components/like-project-button/like-project-button.service.coffee
###

taiga = @.taiga

class LikeProjectButtonService extends taiga.Service
    @.$inject = ["tgResources", "tgCurrentUserService", "tgProjectService"]

    constructor: (@rs, @currentUserService, @projectService) ->

    _getProjectIndex: (projectId) ->
        return @currentUserService.projects
                .get('all')
                .findIndex (project) -> project.get('id') == projectId

    _updateProjects: (projectId, isFan) ->
        projectIndex = @._getProjectIndex(projectId)

        return if projectIndex == -1

        projects = @currentUserService.projects
            .get('all')
            .update projectIndex, (project) ->
                totalFans = project.get("total_fans")

                if isFan then totalFans++ else totalFans--

                return project.merge({
                    is_fan: isFan,
                    total_fans: totalFans
                })

        @currentUserService.setProjects(projects)

    _updateCurrentProject: (isFan) ->
        totalFans = @projectService.project.get("total_fans")

        if isFan then totalFans++ else totalFans--

        project = @projectService.project.merge({
            is_fan: isFan,
            total_fans: totalFans
        })

        @projectService.setProject(project)

    like: (projectId) ->
        return @rs.projects.likeProject(projectId).then =>
            @._updateProjects(projectId, true)
            @._updateCurrentProject(true)

    unlike: (projectId) ->
        return @rs.projects.unlikeProject(projectId).then =>
            @._updateProjects(projectId, false)
            @._updateCurrentProject(false)

angular.module("taigaProjects").service("tgLikeProjectButtonService", LikeProjectButtonService)
