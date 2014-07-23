taiga = @.taiga
module = angular.module("taigaProject", [])

class ProjectController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources"]

    constructor: (@scope, @rs) ->
        @scope.hideMenu = true
        @.projects = []
        @.loadInitialData()

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            @.projects = {'recents': projects.slice(0, 8), 'all': projects.slice(6)}

module.controller("ProjectController", ProjectController)

ProjectsPaginationDirective = () ->
    itemsPerPage = 7
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
        prevBtn = $el.find(".pagination-previous")
        nextBtn = $el.find(".pagination-next")
        container = $el.find("ul")
        pageSize = $el.find(".pagination-list").height()
        containerSize = 0
        animationInProgess = false

        animationEnd = () ->
            animationInProgess = false

        prevBtn.on "click", (event) ->
            event.preventDefault()

            if animationInProgess
                return

            animationInProgess = true
            visible(nextBtn)

            newTop = prevPage(container, pageSize, animationEnd)

            if newTop == 0
                hide(prevBtn)

        nextBtn.on "click", (event) ->
            event.preventDefault()

            if animationInProgess
                return

            animationInProgess = true
            visible(prevBtn)

            newTop = nextPage(container, pageSize, animationEnd)

            if -newTop + pageSize > containerSize
                hide(nextBtn)

        $scope.$watch 'ctrl.projects', () ->
            items = $el.find('li')

            if items.length > itemsPerPage
                containerSize = container.height()
                visible(nextBtn)

module.directive("tgProjectsPagination", ProjectsPaginationDirective)
