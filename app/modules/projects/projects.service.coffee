taiga = @.taiga
groupBy = @.taiga.groupBy

class ProjectsService extends taiga.Service
    @.$inject = ["tgResources", "$rootScope", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @rootScope, @projectUrl, @lightboxFactory) ->
        @._currentUserProjects = Immutable.Map()
        @._currentUserProjectsById = Immutable.Map()
        @._inProgress = false
        @._currentUserProjectsPromise = null

        taiga.defineImmutableProperty @, "currentUserProjects", () => return @._currentUserProjects
        taiga.defineImmutableProperty @, "currentUserProjectsById", () => return @._currentUserProjectsById

        @.fetchProjects()

    getCurrentUserProjects: ->
        return @._currentUserProjectsPromise

    getProjectBySlug: (projectSlug) ->
        return @rs.projects.getProjectBySlug(projectSlug)

    getProjectStats: (projectId) ->
        return @rs.projects.getProjectStats(projectId)

    fetchProjects: ->
        if not @._inProgress
            @._inProgress = true

            @._currentUserProjectsPromise = @rs.users.getProjects(@rootScope.user?.id)
            @._currentUserProjectsPromise.then (projects) =>
                projects = projects.map (project) =>
                    url = @projectUrl.get(project.toJS())

                    project = project.set("url", url)
                    colorized_tags = []

                    if project.get("tags")
                        tags = project.get("tags").sort()

                        colorized_tags = tags.map (tag) ->
                            color = project.get("tags_colors").get(tag)
                            return {name: tag, color: color}

                        project = project.set("colorized_tags", colorized_tags)

                    return project


                @._currentUserProjects = @._currentUserProjects.set("all", projects)
                @._currentUserProjects = @._currentUserProjects.set("recents", projects.slice(0, 10))

                @._currentUserProjectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

                return @.projects

            @._currentUserProjectsPromise.finally =>
                @._inProgress = false

        return @._currentUserProjectsPromise

    newProject: ->
        @lightboxFactory.create("tg-lb-create-project", {
            "class": "wizard-create-project"
        })

    bulkUpdateProjectsOrder: (sortData) ->
        @rs.projects.bulkUpdateOrder(sortData).then =>
            @.fetchProjects()

angular.module("taigaProjects").service("tgProjectsService", ProjectsService)
