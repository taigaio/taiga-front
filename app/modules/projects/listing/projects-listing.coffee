class ProjectsListingController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
    ]

    constructor: (@currentUserService, @projectsService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))

    newProject: ->
        @projectsService.newProject()

angular.module("taigaProjects").controller("ProjectsListing", ProjectsListingController)
