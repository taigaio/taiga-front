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
# File: components/wysiwyg/wysiwyg-code-lightbox/wysiwyg-code-lightbox.directive.coffee
###

WysiwygCodeLightbox = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.$watch 'visible', (visible) ->
            if visible && !el.hasClass('open')
                scope.open = true
                lightboxService.open(el, null, scope.onClose)

                scope.$applyAsync () ->
                    textarea = el[0].querySelector('textarea')
                    if textarea
                        textarea.select()

            else if !visible && el.hasClass('open')
                scope.open = false
                lightboxService.close(el)

    return {
        scope: {
            languages: '<',
            codeLanguage: '<',
            code: '<',
            visible: '<',
            onClose: '&',
            onSave: '&'
        },
        link: link,
        templateUrl: "components/wysiwyg/wysiwyg-code-lightbox/wysiwyg-code-lightbox.html"
    }

angular.module("taigaComponents")
    .directive("tgWysiwygCodeLightbox", ["lightboxService", WysiwygCodeLightbox])
