###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

NewsletterEmailLightboxDirective = (lightboxService, lightboxKeyboardNavigationService, $storageService, $rs, $currentUserService, $rs2, $confirm) ->

    link = (scope, el, attrs, ctrl) ->
        lightboxService.open(el)
        scope.dontAsk = false
        scope.preference = false

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

        scope.closeLightbox = () ->
            lightboxService.close(el)

        scope.setEmail = () ->
            if scope.preference
                $rs2.onPremise.subscribeOnPremiseNewsletter(
                    {
                        "email": $currentUserService.getUser().get('email'),
                        "full_name": $currentUserService.getUser().get('full_name'),
                        "origin_form": 'Newsletter sign-up create'
                    }
                ).then () =>
                    $rs.user.setUserStorage('dont_ask_premise_newsletter', true)
                    scope.closeLightbox()
                .catch () =>
                    $confirm.notify("light-error", "")
            else
                $rs.user.setUserStorage('dont_ask_premise_newsletter', scope.dontAsk)
                scope.closeLightbox()

    return {
        scope: {
            visible: '<',
            openNewsletter: '<',
            onClose: '&',
            onSelectUser: '&',
        },
        templateUrl: 'projects/create/newsletter-email-lightbox/newsletter-email-lightbox.html'
        link: link
    }

NewsletterEmailLightboxDirective.$inject = ['lightboxService', 'lightboxKeyboardNavigationService', "$tgStorage", "tgResources", "tgCurrentUserService", "tgResources", "$tgConfirm"]

angular.module("taigaProjects").directive("tgNewsletterEmailLightbox", NewsletterEmailLightboxDirective)
