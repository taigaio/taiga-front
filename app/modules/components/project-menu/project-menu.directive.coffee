###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: components/project-menu/project-menu.directive.coffee
###

taiga = @.taiga

ProjectMenuDirective = (projectService, lightboxFactory) ->
    link = (scope, el, attrs, ctrl) ->
        projectChange = () ->
            if projectService.project
                ctrl.show()
            else
                ctrl.hide()

        scope.$watch ( () ->
            return projectService.project
        ), projectChange

        fixed = false
        topBarHeight = 48

        window.addEventListener "scroll", () ->
            position = $(window).scrollTop()

            if position > topBarHeight && fixed == false
                el.find('.sticky-project-menu').addClass('unblock')
                fixed = true
            else if position == 0 && fixed == true
                el.find('.sticky-project-menu').removeClass('unblock')
                fixed = false

    return {
        scope: {},
        controller: "ProjectMenu",
        controllerAs: "vm",
        templateUrl: "components/project-menu/project-menu.html",
        link: link
    }

ProjectMenuDirective.$inject = [
    "tgProjectService",
    "tgLightboxFactory"
]

angular.module("taigaComponents").directive("tgProjectMenu", ProjectMenuDirective)
