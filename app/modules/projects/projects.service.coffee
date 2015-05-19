taiga = @.taiga
groupBy = @.taiga.groupBy

class ProjectsService extends taiga.Service
    @.$inject = ["tgResources", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @projectUrl, @lightboxFactory) ->

    getProjectBySlug: (projectSlug) ->
        return @rs.projects.getProjectBySlug(projectSlug)

    getProjectStats: (projectId) ->
        return @rs.projects.getProjectStats(projectId)

    getProjectsByUserId: (userId) ->
        return @rs.projects.getProjectsByUserId(userId)
            .then (projects) =>
                return @._decorate(projects)

    _decorate: (projects) ->
        return projects.map (project) =>
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
            "class": "wizard-create-project"
        })

    bulkUpdateProjectsOrder: (sortData) ->
        @rs.projects.bulkUpdateOrder(sortData).then =>
            @.fetchProjects()

angular.module("taigaProjects").service("tgProjectsService", ProjectsService)
