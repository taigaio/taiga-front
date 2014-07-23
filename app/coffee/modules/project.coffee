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
            example = [
                {'id': 200, 'name': 'sdfdsfs', 'slug': 'sdfsdf'},
                {'id': 201, 'name': 'sdfdsfs1', 'slug': 'sdfsdf'},
                {'id': 2001, 'name': 'sdfdsfs2', 'slug': 'sdfsdf'},
                {'id': 2002, 'name': 'sdfdsfs3', 'slug': 'sdfsdf'},
                {'id': 2003, 'name': 'sdfdsfs4', 'slug': 'sdfsdf'},
                {'id': 2004, 'name': 'sdfdsfs5', 'slug': 'sdfsdf'},
                {'id': 2005, 'name': 'sdfdsfs6', 'slug': 'sdfsdf'},
                {'id': 2006, 'name': 'sdfdsfs7', 'slug': 'sdfsdf'},
                {'id': 2007, 'name': 'sdfdsfs8', 'slug': 'sdfsdf'},
                {'id': 2008, 'name': 'sdfdsfs9', 'slug': 'sdfsdf'},
                {'id': 2009, 'name': 'sdfdsfs10', 'slug': 'sdfsdf'},
                {'id': 20010, 'name': 'sdfdsfs11', 'slug': 'sdfsdf'},
                {'id': 20011, 'name': 'sdfdsfs12', 'slug': 'sdfsdf'},
                {'id': 20012, 'name': 'sdfdsfs13', 'slug': 'sdfsdf'},
                {'id': 20013, 'name': 'sdfdsfs14', 'slug': 'sdfsdf'},
                {'id': 20014, 'name': 'sdfdsfs15', 'slug': 'sdfsdf'},
                {'id': 20015, 'name': 'sdfdsfs16', 'slug': 'sdfsdf'},
                {'id': 20016, 'name': 'sdfdsfs17', 'slug': 'sdfsdf'},
                {'id': 20017, 'name': 'sdfdsfs18', 'slug': 'sdfsdf'},
                {'id': 20018, 'name': 'sdfdsfs19', 'slug': 'sdfsdf'},
                {'id': 20019, 'name': 'sdfdsfs20', 'slug': 'sdfsdf'},
                {'id': 20020, 'name': 'sdfdsfs21', 'slug': 'sdfsdf'},
                {'id': 20021, 'name': 'sdfdsfs22', 'slug': 'sdfsdf'},
                {'id': 20022, 'name': 'sdfdsfs23', 'slug': 'sdfsdf'},
                {'id': 20023, 'name': 'sdfdsfs24', 'slug': 'sdfsdf'},
                {'id': 20024, 'name': 'sdfdsfs25', 'slug': 'sdfsdf'},
                {'id': 20025, 'name': 'sdfdsfs26', 'slug': 'sdfsdf'},
                {'id': 20026, 'name': 'sdfdsfs27', 'slug': 'sdfsdf'}
            ]

            projects = projects.concat(example)
            @.projects = {'recents': projects.slice(0, 8), 'all': projects.slice(6)}

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

        $scope.$watch 'active', (ee) ->
            $timeout () ->
                if $scope.active
                    pageSize = $el.find(".v-pagination-list").height()
                    containerSize = container.height()

                    if containerSize > pageSize
                        visible(nextBtn)
                    else
                        container.css('top', 0)
                        hide(prevBtn)
                        hide(nextBtn)
                else
                    container.css('top', 0)
                    hide(prevBtn)
                    hide(nextBtn)
    return {
        scope: {
            active: '='
        },
        link: link,
        transclude: true,
        templateUrl: 'partials/views/components/pagination.html'
    }

module.directive("tgProjectsPagination", ['$timeout', ProjectsPaginationDirective])
