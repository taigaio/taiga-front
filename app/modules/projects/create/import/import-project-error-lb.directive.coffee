LbImportErrorDirective = (lightboxService) ->
    link = (scope, el, attrs) ->
        lightboxService.open(el)

        scope.close = () ->
            lightboxService.close(el)
            return

    return {
        templateUrl: "projects/create/import/import-project-error-lb.html",
        link: link
    }

LbImportErrorDirective.$inject = ["lightboxService"]

angular.module("taigaProjects").directive("tgLbImportError", LbImportErrorDirective)
