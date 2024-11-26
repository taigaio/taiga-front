###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

