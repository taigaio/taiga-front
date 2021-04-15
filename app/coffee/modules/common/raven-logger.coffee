###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

module = angular.module("taigaCommon")

ExceptionHandlerFactory = ($log, @config) ->
    ravenConfig = @config.get("ravenConfig", null)
    if ravenConfig
      $log.debug "Using the RavenJS exception handler."
      Raven.config(ravenConfig).install()
      return (exception, cause) ->
        $log.error.apply($log, arguments)
        Raven.captureException(exception)

    else
      $log.debug "Using the default logging exception handler."
      return (exception, cause) ->
          $log.error.apply($log, arguments)

module.factory("$exceptionHandler", ["$log", "$tgConfig", ExceptionHandlerFactory])
