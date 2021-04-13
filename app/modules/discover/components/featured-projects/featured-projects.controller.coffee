class FeaturedProjectsController
    @.$inject = [
        "tgDiscoverProjectsService"
    ]

    constructor: (@discoverProjectsService) ->
        taiga.defineImmutableProperty @, "featured", () => return @discoverProjectsService.featured

        @discoverProjectsService.fetchFeatured()

angular.module("taigaDiscover").controller("FeaturedProjects", FeaturedProjectsController)
