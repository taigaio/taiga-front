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
# File: projects/create/warning-user-import-lightbox/warning-user-import-lightbox.directive.coffee
###

WarningUserImportDirective = (lightboxService, lightboxKeyboardNavigationService) ->
    return {
        link: (scope, el, attr) ->
            scope.$watch 'visible', (visible) ->
                if visible && !el.hasClass('open')
                    lightboxService.open(el, scope.onClose).then ->
                        el.find('input').focus()
                        lightboxKeyboardNavigationService.init(el)
                else if !visible && el.hasClass('open')
                    lightboxService.close(el)

        templateUrl:"projects/create/warning-user-import-lightbox/warning-user-import-lightbox.html",
        scope: {
            visible: '<',
            onClose: '&',
            onConfirm: '&'
        }
    }

WarningUserImportDirective.$inject = ['lightboxService', 'lightboxKeyboardNavigationService']

angular.module("taigaProjects").directive("tgWarningUserImportLightbox", WarningUserImportDirective)
