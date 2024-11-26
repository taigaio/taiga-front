###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
