class ProjectsService extends taiga.Service
    @.$inject = ["$q", "$tgResources", "$rootScope", "$projectUrl"]

    constructor: (@q, @rs, @rootscope, @projectUrl) ->
        @.projectsPromise = null
        @.projects = null
        @.callbacks = []

    projectsSuscription: (callback) ->
        @.callbacks.push(callback)

    notifySuscriptors: ->
        for callback in @.callbacks
            callback(@.projects)

    fetchProjects: (updateSuscriptors = true) ->
        @.projectsPromise = @rs.projects.listByMember(@rootscope.user?.id).then (projects) =>
            for project in projects
                project.url = @projectUrl.get(project)

            @.projects = {'recents': projects.slice(0, 8), 'all': projects}
            if updateSuscriptors
                @.notifySuscriptors()

            return @.projects

        return @.projectsPromise

    getProjects: (updateSuscriptors = false) ->
        if not @.projectsPromise?
            promise = @.fetchProjects(not updateSuscriptors)
        else
            promise = @.projectsPromise

        if updateSuscriptors
            promise.then =>
                @.notifySuscriptors()

        return promise

    bulkUpdateProjectsOrder: (sortData) ->
        @rs.projects.bulkUpdateOrder(sortData).then =>
            @.fetchProjects()

angular.module("taigaProjects").service("tgProjects", ProjectsService)
