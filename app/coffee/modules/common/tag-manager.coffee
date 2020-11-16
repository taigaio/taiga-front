###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: modules/common/analytics.coffee
###

taiga = @.taiga
module = angular.module("taigaCommon")


class TagManagerService extends taiga.Service
    @.$inject = ["$rootScope", "$log", "$tgConfig", "$window", "$document", "$location"]

    constructor: (@rootscope, @log, @config, @win, @doc, @location) ->
        @.initialized = false

        conf = @config.get("tagManager", {})

        @.accountId = conf.accountId


    initialize: ->
        if not @.accountId
            @log.debug "Tag Manager: no account id provided. Disabling."
            return

        @.injectTagManager()
        @.initialized = true

    injectTagManager: ->
        fn = `(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
              new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
              j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;
              j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl;
              f.parentNode.insertBefore(j,f);})`
        fn(window, document, "script", "dataLayer", @.accountId)


module.service("$tgTagManager", TagManagerService)
