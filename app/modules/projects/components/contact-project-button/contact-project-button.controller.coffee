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
