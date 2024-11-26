###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
