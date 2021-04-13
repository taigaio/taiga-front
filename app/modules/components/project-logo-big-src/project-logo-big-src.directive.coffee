ProjectLogoBigSrcDirective = (projectLogoService) ->
    link = (scope, el, attrs) ->
        scope.$watch 'project', (project) ->
            project = Immutable.fromJS(project) # Necesary for old code

            return if not project

            projectLogo = project.get('logo_big_url')

            if projectLogo
                el.attr('src', projectLogo)
                el.css('background', "")
            else
                logo = projectLogoService.getDefaultProjectLogo(project.get('slug'), project.get('id'))
                el.attr('src', logo.src)
                el.css('background', logo.color)

    return {
        link: link
        scope: {
             project: "=tgProjectLogoBigSrc"
        }
    }

ProjectLogoBigSrcDirective.$inject = [
    "tgProjectLogoService"
]

angular.module("taigaComponents").directive("tgProjectLogoBigSrc", ProjectLogoBigSrcDirective)
