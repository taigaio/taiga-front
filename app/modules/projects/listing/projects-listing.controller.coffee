class ProjectsListingController
    @.$inject = [
        "tgProjectsService"
    ]

    constructor: (@projectsService) ->
        taiga.defineImmutableProperty(@, "projects", () => @projectsService.currentUserProjects.get("all"))

    newProject: ->
        @projectsService.newProject()

angular.module("taigaProjects").controller("ProjectsListing", ProjectsListingController)
