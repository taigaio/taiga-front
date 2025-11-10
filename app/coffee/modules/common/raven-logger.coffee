###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

module = angular.module("taigaCommon")

ExceptionHandlerFactory = ($log, @config, $injector) ->
    ravenConfig = @config.get("ravenConfig", null)
    
    # Delay getting performance monitor to avoid circular dependency
    getPerformanceMonitor = ->
        try
            return $injector.get("tgPerformanceMonitor")
        catch
            return null
    
    if ravenConfig
      $log.debug "Using the RavenJS exception handler."
      Raven.config(ravenConfig).install()
      return (exception, cause) ->
        $log.error.apply($log, arguments)
        Raven.captureException(exception)
        performanceMonitor = getPerformanceMonitor()
        performanceMonitor?.recordError(exception, {cause: cause, source: "angular"})

    else
      $log.debug "Using the default logging exception handler."
      return (exception, cause) ->
          $log.error.apply($log, arguments)
          performanceMonitor = getPerformanceMonitor()
          performanceMonitor?.recordError(exception, {cause: cause, source: "angular"})

module.factory("$exceptionHandler", ["$log", "$tgConfig", "$injector", ExceptionHandlerFactory])
