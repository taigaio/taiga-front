###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class FiltersStorageService extends taiga.Service
    @.$inject = ["$tgStorage", "$routeParams"]

    constructor: (@storage, @params) ->

    generateHash: (components=[]) ->
        components = _.map(components, (x) -> JSON.stringify(x))
        return hex_sha1(components.join(":"))
