###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
