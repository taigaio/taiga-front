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
# File: modules/events.coffee
###

taiga = @.taiga

module = angular.module("taigaEvents", [])


class EventsService
    constructor: (@win, @log, @config, @auth) ->
        _.bindAll(@)

    initialize: (sessionId) ->
        @.sessionId = sessionId
        @.subscriptions = {}

        if @win.WebSocket is undefined
            @log.debug "WebSockets not supported on your browser"

    setupConnection: ->
        @.stopExistingConnection()

        wshost = @config.get("eventsHost", "localhost:8888")
        wsscheme = @config.get("eventsScheme", "ws")
        url = "#{wsscheme}://#{wshost}/events"

        @.ws = new @win.WebSocket(url)
        @.ws.addEventListener("open", @.onOpen)
        @.ws.addEventListener("message", @.onMessage)
        @.ws.addEventListener("error", @.onError)
        @.ws.addEventListener("close", @.onClose)

    stopExistingConnection: ->
        if @.ws is undefined
            return

        @.ws.close()
        @.ws.removeEventListener("open", @.onOpen)
        @.ws.removeEventListener("close", @.onClose)
        @.ws.removeEventListener("error", @.onError)
        @.ws.removeEventListener("message", @.onMessage)

        delete @.ws

    onOpen: ->
        @log.debug("WebSocket connection opened")
        token = @auth.getToken()

        message = {
            cmd: "auth"
            data: {token: token, sessionId: @.sessionId}
        }

        @.ws.send(JSON.stringify(message))

    onMessage: (event) ->
        @.log.debug "WebSocket message received: #{event.data}"

        data = JSON.parse(event.data)
        routingKey = data.routing_key

        if not @.subscriptions[routingKey]?
            return

        subscription = @.subscriptions[routingKey]
        subscription.scope.$apply ->
            subscription.callback(data.data)

    onError: (error) ->
        @log.error("WebSocket error: #{error}")

    onClose: ->
        @log.debug("WebSocket closed.")

    subscribe: (scope, routingKey, callback) ->
        subscription = {
            scope: scope,
            routingKey: routingKey,
            callback: callback
        }

        message = {
            "cmd": "subscribe",
            "routing_key": routingKey
        }

        @.subscriptions[routingKey] = subscription
        @.ws.send(JSON.stringify(message))
        scope.$on("$destroy", => @.unsubscribe(routingKey))

    unsubscribe: (routingKey) ->
        message = {
            "cmd": "unsubscribe",
            "routing_key": routingKey
        }

        @.ws.send(JSON.stringify(message))


class EventsProvider
    setSessionId: (sessionId) ->
        @.sessionId = sessionId

    $get: ($win, $log, $conf, $auth) ->
        service = new EventsService($win, $log, $conf, $auth)
        service.initialize(@.sessionId)
        return service

    @.prototype.$get.$inject = ["$window", "$log", "$tgConfig", "$tgAuth"]

module.provider("$tgEvents", EventsProvider)
