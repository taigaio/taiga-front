###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

SelectImportUserLightboxDirective = (lightboxService, lightboxKeyboardNavigationService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.$watch 'vm.visible', (visible) ->
            if visible && !el.hasClass('open')
                ctrl.start()
                lightboxService.open(el, null, scope.vm.onClose).then ->
                    el.find('input').focus()
                    lightboxKeyboardNavigationService.init(el)
            else if !visible && el.hasClass('open')
                lightboxService.close(el).then () ->
                    ctrl.userEmail = ''
                    ctrl.usersSearch = ''

    return {
        controller: "SelectImportUserLightboxCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            user: '<',
            visible: '<',
            onClose: '&',
            onSelectUser: '&',
            selectableUsers: '<',
            isPrivate: '<',
            limitMembersPrivateProject: '<',
            limitMembersPublicProject: '<',
            displayEmailSelector: '<'
        },
        templateUrl: 'projects/create/select-import-user-lightbox/select-import-user-lightbox.html'
        link: link
    }

SelectImportUserLightboxDirective.$inject = ['lightboxService', 'lightboxKeyboardNavigationService']

angular.module("taigaProjects").directive("tgSelectImportUserLightbox", SelectImportUserLightboxDirective)
