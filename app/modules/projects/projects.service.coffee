taiga = @.taiga
groupBy = @.taiga.groupBy

class ProjectsService extends taiga.Service
    @.$inject = ["$tgResources", "$rootScope", "$projectUrl", "tgLightboxFactory"]

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

    fetchProjects: ->
        if not @._inProgress
            @._inProgress = true

            @._currentUserProjectsPromise = @rs.projects.listByMember(@rootScope.user?.id)
            @._currentUserProjectsPromise.then (projects) =>
                _.map projects, (project) =>
                    project.url = @projectUrl.get(project)

                    project.colorized_tags = []

                    if project.tags
                        tags = project.tags.sort()

                        project.colorized_tags = _.map tags, (tag) ->
                            color = project.tags_colors[tag]
                            return {name: tag, color: color}

                @._currentUserProjects = Immutable.fromJS({
                    all: projects,
                    recents: projects.slice(0, 10)
                })

                @._currentUserProjectsById = Immutable.fromJS(groupBy(projects, (p) -> p.id))

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
