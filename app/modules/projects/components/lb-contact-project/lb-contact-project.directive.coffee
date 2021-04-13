ContactProjectLbDirective = (lightboxService) ->

    @.inject = ['lightboxService']

    link = (scope, el) ->
        lightboxService.open(el)

    return {
        controller: "ContactProjectLbCtrl",
        bindToController: {
            project: '='
        }
        controllerAs: "vm",
        templateUrl: "projects/components/lb-contact-project/lb-contact-project.html",
        link: link
    }

angular.module("taigaProjects").directive("tgLbContactProject", ["lightboxService", ContactProjectLbDirective])
