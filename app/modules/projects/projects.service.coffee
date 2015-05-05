taiga = @.taiga
groupBy = @.taiga.groupBy

class ProjectsService extends taiga.Service
    @.$inject = ["$tgResources", "$rootScope", "$projectUrl", "tgLightboxFactory"]

    constructor: (@rs, @rootScope, @projectUrl, @lightboxFactory) ->
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()
        @._inProgress = false
        @._projectsPromise = null

        taiga.defineImmutableProperty @, "projects", () => return @._projects
        taiga.defineImmutableProperty @, "projectsById", () => return @._projectsById

        @.fetchProjects()

    fetchProjects: ->
        if not @._inProgress
            @._inProgress = true

            @._projectsPromise = @rs.projects.listByMember(@rootScope.user?.id)
            @._projectsPromise.then (projects) =>
                for project in projects
                    project.url = @projectUrl.get(project)

                @._projects = Immutable.fromJS({
                    all: projects,
                    recents: projects.slice(0, 10)
                })

                @._projectsById = Immutable.fromJS(groupBy(projects, (p) -> p.id))

                return @.projects

            @._projectsPromise.finally =>
                @._inProgress = false

        return @._projectsPromise

    newProject: ->
        @lightboxFactory.create("tg-lb-create-project", {
            "class": "wizard-create-project"
        })

    bulkUpdateProjectsOrder: (sortData) ->
        @rs.projects.bulkUpdateOrder(sortData).then =>
            @.fetchProjects()

angular.module("taigaProjects").service("tgProjectsService", ProjectsService)
