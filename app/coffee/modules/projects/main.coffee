taiga = @.taiga
module = angular.module("taigaProject")

class ProjectNavController extends taiga.Controller
    @.$inject = ["$rootScope"]

    constructor: (@rootscope) ->

    newProject: ->
        @rootscope.$broadcast("projects:create")

module.controller("ProjectNavController", ProjectNavController)

class ProjectsController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources", "$rootScope", "$tgNavUrls"]

    constructor: (@scope, @rs, @rootscope, @navurls) ->
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
    @.$inject = ["$scope", "$tgResources", "$tgRepo", "$routeParams", "$q", "$rootScope"]

    constructor: (@scope, @rs, @repo, @params, @q, @rootscope) ->
        @scope.hideMenu = false
        @.loadInitialData()

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

ProjectsPaginationDirective = ($timeout) ->
    nextPage = (element, pageSize, callback) ->
        top = parseInt(element.css('top'), 10)
        newTop = top - pageSize

        element.animate({"top": newTop}, callback);

        return newTop

    prevPage = (element, pageSize, callback) ->
        top = parseInt(element.css('top'), 10)
        newTop = top + pageSize

        element.animate({"top": newTop}, callback);

        return newTop

    visible = (element) ->
        element.css('visibility', 'visible')

    hide = (element) ->
        element.css('visibility', 'hidden')

    link = ($scope, $el, $attrs) ->
        prevBtn = $el.find(".v-pagination-previous")
        nextBtn = $el.find(".v-pagination-next")
        container = $el.find("ul")

        pageSize = 0
        containerSize = 0

        remove = () ->
            container.css('top', 0)
            hide(prevBtn)
            hide(nextBtn)

        prevBtn.on "click", (event) ->
            event.preventDefault()

            if container.is(':animated')
                return

            visible(nextBtn)

            newTop = prevPage(container, pageSize)

            if newTop == 0
                hide(prevBtn)

        nextBtn.on "click", (event) ->
            event.preventDefault()

            if container.is(':animated')
                return

            visible(prevBtn)

            newTop = nextPage(container, pageSize)

            if -newTop + pageSize > containerSize
                hide(nextBtn)

        $scope.$watch 'active', () ->
            #wait digest end
            $timeout () ->
                if $scope.active
                    pageSize = $el.find(".v-pagination-list").height()
                    containerSize = container.height()

                    if containerSize > pageSize
                        visible(nextBtn)
                    else
                        remove()
                else
                    remove()

    return {
        scope: {
            active: '='
        },
        link: link,
        transclude: true,
        template: """
            <a class="v-pagination-previous icon icon-arrow-up " href=""></a>
            <div class="v-pagination-list" ng-transclude=""></div>
            <a class="v-pagination-next icon icon-arrow-bottom" href=""></a>
        """
    }

module.directive("tgProjectsPagination", ['$timeout', ProjectsPaginationDirective])
