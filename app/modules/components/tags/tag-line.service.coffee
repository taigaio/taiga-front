###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaCommon')

class TagLineService extends taiga.Service
    @.$inject = []

    constructor: () ->

    checkPermissions: (myPermissions, projectPermissions) ->
        return _.includes(myPermissions, projectPermissions)

    createColorsArray: (projectTagColors) ->
        return _.map(projectTagColors, (index, value) ->
            return [value, index]
        )

module.service("tgTagLineService", TagLineService)
