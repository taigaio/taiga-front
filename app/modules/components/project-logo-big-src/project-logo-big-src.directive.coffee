###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: components/project-logo-big-src/project-logo-big-src.directive.coffee
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
