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
debounce = @.taiga.debounce
bindMethods = @.taiga.bindMethods

NOTIFICATION_MSG = {
    "success":
        title: "Everything is ok"
        message: "Our Oompa Loompas saved all your changes!"
    "error":
        title: "Oops, something happened..."
        message: "Our Oompa Loompas are sad, your changes were not saved!"
    "light-error":
        title: "Oops, something happened..."
        message: "Our Oompa Loompas are sad, your changes were not saved!"
}


class ConfirmService extends taiga.Service
    @.$inject = ["$q", "lightboxService", "$tgLoading"]

    constructor: (@q, @lightboxService, @loading) ->
        bindMethods(@)

    hide: (el)->
        if el
            @lightboxService.close(el)

            el.off(".confirm-dialog")

    ask: (title, subtitle, message, lightboxSelector=".lightbox-generic-ask") ->
        el = angular.element(lightboxSelector)

        # Render content
        el.find("h2.title").html(title)
        el.find("span.subtitle").html(subtitle)
        el.find("span.message").html(message)

        defered = @q.defer()

        # Assign event handlers
        el.on "click.confirm-dialog", "a.button-green", debounce 2000, (event) =>
            event.preventDefault()
            target = angular.element(event.currentTarget)
            @loading.start(target)
            defered.resolve (ok=true) =>
                @loading.finish(target)
                if ok
                    @.hide(el)

        el.on "click.confirm-dialog", "a.button-red", (event) =>
            event.preventDefault()
            defered.reject()
            @.hide(el)

        @lightboxService.open(el)

        return defered.promise

    askOnDelete: (title, message) ->
        return @.ask(title, "Are you sure you want to delete?", message) #TODO: i18n

    askChoice: (title, subtitle, choices, replacement, warning, lightboxSelector=".lightbox-ask-choice") ->
        el = angular.element(lightboxSelector)

        # Render content
        el.find(".title").html(title)
        el.find(".subtitle").html(subtitle)

        if replacement
            el.find(".replacement").html(replacement)
        else
            el.find(".replacement").remove()

        if warning
            el.find(".warning").html(warning)
        else
            el.find(".warning").remove()

        choicesField = el.find(".choices")
        choicesField.html('')
        _.each choices, (value, key) ->
            choicesField.append(angular.element("<option value='#{key}'>#{value}</option>"))
        defered = @q.defer()

        # Assign event handlers
        el.on "click.confirm-dialog", "a.button-green", debounce 2000, (event) =>
            event.preventDefault()
            target = angular.element(event.currentTarget)
            @loading.start(target)
            defered.resolve {
                selected: choicesField.val()
                finish: =>
                    @loading.finish(target)
                    @.hide(el)
            }

        el.on "click.confirm-dialog", "a.button-red", (event) =>
            event.preventDefault()
            defered.reject()
            @.hide(el)

        @lightboxService.open(el)

        return defered.promise

    error: (message) ->
        el = angular.element(".lightbox-generic-error")

        # Render content
        el.find("h2.title").html(message)
        defered = @q.defer()

        # Assign event handlers
        el.on "click.confirm-dialog", "a.button-green", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide(el)

        el.on "click.confirm-dialog", "a.close", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide(el)

        @lightboxService.open(el)

        return defered.promise

    success: (message) ->
        el = angular.element(".lightbox-generic-success")

        # Render content
        el.find("h2.title").html(message)
        defered = @q.defer()

        # Assign event handlers
        el.on "click.confirm-dialog", "a.button-green", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide(el)

        el.on "click.confirm-dialog", "a.close", (event) =>
            event.preventDefault()
            defered.resolve()
            @.hide(el)

        @lightboxService.open(el)

        return defered.promise

    notify: (type, message, title) ->
        # NOTE: Typesi are: error, success, light-error
        #       See partials/components/notification-message.jade)
        #       Add default texts to NOTIFICATION_MSG for new notification types

        selector = ".notification-message-#{type}"
        el = angular.element(selector)

        if title
            el.find("h4").html(title)
        else
            el.find("h4").html(NOTIFICATION_MSG[type].title)

        if message
            el.find("p").html(message)
        else
            el.find("p").html(NOTIFICATION_MSG[type].message)

        body = angular.element("body")
        body.find(".notification-message .notification-light")
            .removeClass('active')
            .addClass('inactive')

        body.find(selector)
            .removeClass('inactive')
            .addClass('active')

        if @.tsem
            cancelTimeout(@.tsem)

        time = if type == 'error' or type == 'light-error' then 3500 else 1500

        @.tsem = timeout time, =>
            body.find(selector)
                .removeClass('active')
                .addClass('inactive')

            delete @.tsem

        el.on "click", ".icon-delete", (event) =>
            body.find(selector)
                .removeClass('active')
                .addClass('inactive')


module = angular.module("taigaCommon")
module.service("$tgConfirm", ConfirmService)
