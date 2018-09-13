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
# File: modules/common/raven-logger.coffee
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
