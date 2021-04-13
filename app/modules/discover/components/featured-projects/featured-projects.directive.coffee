FeaturedProjectsDirective = () ->
    link = (scope, el, attrs) ->

    return {
        controller: "FeaturedProjects"
        controllerAs: "vm",
        templateUrl: "discover/components/featured-projects/featured-projects.html",
        scope: {},
        link: link
    }

FeaturedProjectsDirective.$inject = []

angular.module("taigaDiscover").directive("tgFeaturedProjects", FeaturedProjectsDirective)
