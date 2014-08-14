taiga = @.taiga
module = angular.module("taigaProject")


class ProjectsController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources", "$rootScope", "$tgNavUrls", "$tgAuth", "$location", "$appTitle", "$projectUrl"]

    constructor: (@scope, @rs, @rootscope, @navurls, $auth, $location, appTitle, @projectUrl) ->
        appTitle.set("Projects")

        if !$auth.isAuthenticated()
            $location.path("/login")

        @scope.hideMenu = true
        @.projects = []
        @.loadInitialData()

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            @.projects = {'recents': projects.slice(0, 8), 'all': projects.slice(8)}
            for project in projects
                project.url = @projectUrl.get(project)

    newProject: ->
        @rootscope.$broadcast("projects:create")

module.controller("ProjectsController", ProjectsController)

class ProjectController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources", "$tgRepo", "$routeParams", "$q", "$rootScope", "$appTitle"]

    constructor: (@scope, @rs, @repo, @params, @q, @rootscope, @appTitle) ->
        @scope.hideMenu = false
        @.loadInitialData()
            .then () =>
                @appTitle.set(@scope.project.name)

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise
                .then(=> @.loadPageData())
                .then(=> @scope.$emit("project:loaded", @scope.project))

    loadPageData: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadProject()])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            return project

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @scope.stats = stats
            return stats


module.controller("ProjectController", ProjectController)
