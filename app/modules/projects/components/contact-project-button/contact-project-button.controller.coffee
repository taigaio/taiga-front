###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ContactProjectButtonController
    @.$inject = ['tgLightboxFactory']

    constructor: (@lightboxFactory)->

    launchContactForm: () ->
        @lightboxFactory.create(
            'tg-lb-contact-project',
            {
                "class": "lightbox lightbox-contact-project e2e-lightbox-contact-project",
                "project": "project"
            },
            {
                "project": @.project
            }
        )


angular.module("taigaProjects").controller("ContactProjectButtonCtrl", ContactProjectButtonController)
