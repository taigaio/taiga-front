###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
