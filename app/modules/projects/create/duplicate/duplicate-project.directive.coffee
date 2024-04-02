###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

DuplicateProjectDirective = () ->

    link = (scope, el, attr, ctrl) ->

    return {
        link: link,
        templateUrl:"projects/create/duplicate/duplicate-project.html",
        controller: "DuplicateProjectCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {}
    }

DuplicateProjectDirective.$inject = []

angular.module("taigaProjects").directive("tgDuplicateProject", DuplicateProjectDirective)
