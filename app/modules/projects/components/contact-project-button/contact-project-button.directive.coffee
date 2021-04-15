###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ContactProjectButtonDirective = ->
    return {
        scope: {}
        controller: "ContactProjectButtonCtrl",
        bindToController: {
            project: '='
            layout: '@'
        }
        controllerAs: "vm",
        templateUrl: "projects/components/contact-project-button/contact-project-button.html",
    }

angular.module("taigaProjects").directive("tgContactProjectButton", ContactProjectButtonDirective)
