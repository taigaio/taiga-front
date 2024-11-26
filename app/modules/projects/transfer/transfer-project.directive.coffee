###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaProjects')

TransferProjectDirective = () ->
    link = (scope, el, attrs, ctrl) ->
      ctrl.initialize()

    return {
        link: link,
        scope: {},
        bindToController: {
            project: "="
        },
        templateUrl: "projects/transfer/transfer-project.html",
        controller: 'TransferProjectController',
        controllerAs: 'vm'
    }

module.directive('tgTransferProject', TransferProjectDirective)
