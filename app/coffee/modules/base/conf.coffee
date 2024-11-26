###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class ConfigurationService
    constructor: () ->
        @.config = window.taigaConfig

    get: (key, defaultValue=null) ->
        if _.has(@.config, key)
            return @.config[key]
        return defaultValue


module = angular.module("taigaBase")
module.service("$tgConfig", ConfigurationService)
