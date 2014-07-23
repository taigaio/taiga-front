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
    nextPage = (element, pageSize) ->
        top = parseInt(element.css('top'), 10)
        newTop = top - pageSize

        element.animate({"top": newTop});

        return newTop

    prevPage = (element, pageSize) ->
        top = parseInt(element.css('top'), 10)
        newTop = top + pageSize

        element.animate({"top": newTop});

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

        prevBtn.on "click", (event) ->
            event.preventDefault()

            visible(nextBtn)

            if -prevPage(container, pageSize) == 0
                hide(prevBtn)

        nextBtn.on "click", (event) ->
            event.preventDefault()

            visible(prevBtn)

            if -nextPage(container, pageSize) + pageSize > containerSize
                hide(nextBtn)

        $scope.$watch 'ctrl.projects', () ->
            items = $el.find('li')

            if items.length > itemsPerPage
                containerSize = container.height()
                visible(nextBtn)

module.directive("tgProjectsPagination", ProjectsPaginationDirective)
