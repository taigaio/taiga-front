###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
