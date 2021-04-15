###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
