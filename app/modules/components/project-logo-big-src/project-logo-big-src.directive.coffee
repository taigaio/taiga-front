###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

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
