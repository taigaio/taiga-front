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
