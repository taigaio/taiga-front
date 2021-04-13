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
