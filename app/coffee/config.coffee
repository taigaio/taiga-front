###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: config.coffee
###

taiga = @.taiga

class ConfigService extends taiga.Service
    defaults: {
        host: "localhost:8000"
        scheme: "http"
        defaultLanguage: "en"
        debug: false
        languageOptions: {
            "es": "Spanish"
            "en": "English"
        }
        allowPublicRegistration: false
    }

    initialize: (localconfig) ->
        defaults = _.clone(@.defaults, true)
        @.config = _.merge(defaults, localconfig)

    get: (key, defaultValue=null) ->
        return @.config[key] || defaultValue

# Initialize config loading local configuration.
init = ($log, localconfig, config) ->
    $log.debug("Initializing configuration", localconfig)
    config.initialize(localconfig)

module = angular.module("taigaConfig", ["taigaLocalConfig"])
module.service("$tgConfig", ConfigService)
module.run(["$log", "localconfig", "$tgConfig", init])
