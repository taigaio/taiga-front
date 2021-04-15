###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($repo) ->
    service = {
        list: -> return $repo.queryMany("locales")
    }

    return (instance) ->
        instance.locales = service


module = angular.module("taigaResources")
module.factory("$tgLocalesResourcesProvider", ["$tgRepo", resourceProvider])

