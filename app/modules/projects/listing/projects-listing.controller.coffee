class ProjectsListingController
    @.$inject = [
        "tgCurrentUserService"
    ]

    constructor: (@currentUserService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))

angular.module("taigaProjects").controller("ProjectsListing", ProjectsListingController)
