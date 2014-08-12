taiga = @.taiga
module = angular.module("taigaProject")


class ProjectsController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources", "$rootScope", "$tgNavUrls", "$tgAuth", "$location", "$appTitle"]

    constructor: (@scope, @rs, @rootscope, @navurls, $auth, $location, appTitle) ->
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
                if project.is_backlog_activated and project.my_permissions.indexOf("view_us")>-1
                    url = @navurls.resolve("project-backlog")
                else if project.is_kanban_activated and project.my_permissions.indexOf("view_us")>-1
                    url = @navurls.resolve("project-kanban")
                else if project.is_wiki_activated and project.my_permissions.indexOf("view_wiki_pages")>-1
                    url = @navurls.resolve("project-wiki")
                else if project.is_issues_activated and project.my_permissions.indexOf("view_issues")>-1
                    url = @navurls.resolve("project-issues")
                else
                    url = @navurls.resolve("project")

                project.url = @navurls.formatUrl(url, {'project': project.slug})

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
