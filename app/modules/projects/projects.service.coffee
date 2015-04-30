taiga = @.taiga
groupBy = @.taiga.groupBy

class ProjectsService extends taiga.Service
    @.$inject = ["$tgResources", "$rootScope", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @rootScope, @projectUrl, @lightboxFactory) ->
        @.projects = Immutable.Map()
        @.projectsById = Immutable.Map()
        @._inProgress = false
        @.projectsPromise = null
        @.fetchProjects()

    fetchProjects: ->
        if not @._inProgress
            @._inProgress = true

            @.projectsPromise = @rs.projects.listByMember(@rootScope.user?.id)
            @.projectsPromise.then (projects) =>
                for project in projects
                    project.url = @projectUrl.get(project)

                @.projects = Immutable.fromJS({
                    all: projects,
                    recents: projects.slice(0, 10)
                })

                @.projectsById = Immutable.fromJS(groupBy(projects, (p) -> p.id))

                return @.projects

            @.projectsPromise.finally =>
                @._inProgress = false

        return @.projectsPromise

    newProject: ->
        @lightboxFactory.create("tg-lb-create-project", {
            "class": "wizard-create-project"
        })

    bulkUpdateProjectsOrder: (sortData) ->
        @rs.projects.bulkUpdateOrder(sortData).then =>
            @.fetchProjects()

angular.module("taigaProjects").service("tgProjectsService", ProjectsService)
