taiga = @.taiga
module = angular.module("taigaProject", [])

class ProjectsController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources"]

    constructor: (@scope, @rs) ->
        @scope.hideMenu = true
        @.projects = []
        @.loadInitialData()

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            @.projects = {'recents': projects.slice(0, 8), 'all': projects.slice(6)}

module.controller("ProjectsController", ProjectsController)

class ProjectController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources", "$tgRepo", "$routeParams", "$q"]

    constructor: (@scope, @rs, @repo, @params, @q) ->
        @scope.hideMenu = true
        @.loadInitialData()

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadPageData())

    loadPageData: ->
        return @q.all([
            @.loadProjectStats(),
            @.loadProject()])

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @.project = project
            return project

    loadProjectStats: ->
        return @rs.projects.stats(@scope.projectId).then (stats) =>
            @.stats = stats
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
