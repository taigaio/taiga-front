###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
