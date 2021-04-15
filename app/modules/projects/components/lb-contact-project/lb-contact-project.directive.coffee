###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ContactProjectLbDirective = (lightboxService) ->

    @.inject = ['lightboxService']

    link = (scope, el) ->
        lightboxService.open(el)

    return {
        controller: "ContactProjectLbCtrl",
        bindToController: {
            project: '='
        }
        controllerAs: "vm",
        templateUrl: "projects/components/lb-contact-project/lb-contact-project.html",
        link: link
    }

angular.module("taigaProjects").directive("tgLbContactProject", ["lightboxService", ContactProjectLbDirective])
