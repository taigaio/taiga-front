###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
