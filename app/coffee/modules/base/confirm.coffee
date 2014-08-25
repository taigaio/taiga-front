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
cancelTimeout = @.taiga.cancelTimeout


NOTIFICATION_MSG = {
    "success":
        title: "Everything is ok"
        message: "Our oompa Loompas saved all your changes!"
    "error":
        title: "Oops, something happened..."
        message: "Our oompa Loompas are sad, your changes were not saved!"
    "light-error":
        title: "Oops, something happened..."
        message: "Our oompa Loompas are sad, your changes were not saved!"
}

class ConfirmService extends taiga.Service
    @.$inject = ["$q", "lightboxService"]

    constructor: (@q, @lightboxService) ->
        _.bindAll(@)

    hide: ->
        if @.el
            @lightboxService.close(@.el)

            @.el.off(".confirm-dialog")
            delete @.el

    ask: (title, subtitle, lightboxSelector=".lightbox_confirm-delete") ->
        @.el = angular.element(lightboxSelector)

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

        @lightboxService.open(@.el)

        return defered.promise

    askChoice: (title, subtitle, choices, lightboxSelector=".lightbox-ask-choice") ->
        @.el = angular.element(lightboxSelector)

        # Render content
        @.el.find("h2.title").html(title)
        @.el.find("span.subtitle").html(subtitle)
        choicesField = @.el.find("select.choices")
        choicesField.html('')
        _.each choices, (value, key) ->
            choicesField.append(angular.element("<option value='#{key}'>#{value}</option>"))
        defered = @q.defer()

        # Assign event handlers
        @.el.on "click.confirm-dialog", "a.button-green", (event) =>
            event.preventDefault()
            defered.resolve(choicesField.val())
            @.hide()

        @.el.on "click.confirm-dialog", "a.button-red", (event) =>
            event.preventDefault()
            defered.reject()
            @.hide()

        @lightboxService.open(@.el)

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

        @.el.on "click.confirm-dialog", "a.close", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide()

        @lightboxService.open(@.el)

        return defered.promise

    success: (message) ->
        @.el = angular.element(".lightbox-generic-success")

        # Render content
        @.el.find("h2.title").html(message)
        defered = @q.defer()

        # Assign event handlers
        @.el.on "click.confirm-dialog", "a.button-green", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide()

        @.el.on "click.confirm-dialog", "a.close", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide()

        @lightboxService.open(@.el)

        return defered.promise

    notify: (type, message, title) ->
        # NOTE: Typesi are: error, success, light-error
        #       See partials/components/notification-message.jade)
        #       Add default texts to NOTIFICATION_MSG for new notification types

        selector = ".notification-message-#{type}"
        @.el = angular.element(selector)

        if title
           @.el.find("h4").html(title)
        else
           @.el.find("h4").html(NOTIFICATION_MSG[type].title)

        if message
            @.el.find("p").html(message)
        else
            @.el.find("p").html(NOTIFICATION_MSG[type].message)

        body = angular.element("body")
        body.find(".notification-message .notification-light")
            .removeClass('active')
            .addClass('inactive')

        body.find(selector)
            .removeClass('inactive')
            .addClass('active')

        if @.tsem
            cancelTimeout(@.tsem)

        @.tsem = timeout 1500, =>
            body.find(selector)
                .removeClass('active')
                .addClass('inactive')

            delete @.tsem

        @.el.on "click", ".icon-delete", (event) =>
            body.find(selector)
                .removeClass('active')
                .addClass('inactive')


module = angular.module("taigaBase")
module.service("$tgConfirm", ["$q", "lightboxService", ConfirmService])
