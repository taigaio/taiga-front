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
# File: modules/base/confirm.coffee
###

taiga = @.taiga
timeout = @.taiga.timeout


class ConfirmService extends taiga.Service
    @.$inject = ["$q"]

    constructor: (@q) ->
        _.bindAll(@)

    hide: ->
        if @.el
            @.el.addClass("hidden")
            @.el.off(".confirm-dialog")
            delete @.el

    ask: (title, subtitle) ->
        @.el = angular.element(".lightbox_confirm-delete")

        # Render content
        @.el.find("h2.title").html(title)
        @.el.find("span.subtitle").html(subtitle)
        defered = @q.defer()

        # Assign event handlers
        @.el.on "click.confirm-dialog", "a.button-green", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide()

        @.el.on "click.confirm-dialog", "a.button-red", (event) =>
            event.preventDefault()
            defered.reject()
            @.hide()

        @.el.removeClass("hidden")
        return defered.promise

    error: (message) ->
        @.el = angular.element(".lightbox-generic-error")

        # Render content
        @.el.find("h2.title").html(message)
        defered = @q.defer()

        # Assign event handlers
        @.el.on "click.confirm-dialog", "a.button-green", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide()

        @.el.removeClass("hidden")
        return defered.promise

    notify: (type, message) ->
        # TODO: at this momment the message is ignored
        # because the notification message not permits
        # custom messages.
        #
        # Types: error, success

        selector = ".notification-message-#{type}"

        body = angular.element("body")
        body.find(".notification-message").addClass("hidden")
        body.find(selector).removeClass("hidden")

        if @.tsem
            cancelTimeout(@.tsem)

        @.tsem = timeout 4000, =>
            body.find(selector).addClass("hidden")
            delete @.sem

module = angular.module("taigaBase")
module.service("$tgConfirm", ["$q", ConfirmService])
