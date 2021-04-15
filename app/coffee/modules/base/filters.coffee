###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

class FiltersStorageService extends taiga.Service
    @.$inject = ["$tgStorage", "$routeParams"]

    constructor: (@storage, @params) ->

    generateHash: (components=[]) ->
        components = _.map(components, (x) -> JSON.stringify(x))
        return hex_sha1(components.join(":"))
