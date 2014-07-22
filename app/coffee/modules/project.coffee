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
            @.projects = projects
            return projects

module.controller("ProjectController", ProjectController)
