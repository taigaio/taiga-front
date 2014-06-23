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

class ConfirmService extends taiga.Service
    @.$inject = ["$q"]

    constructor: (@q) ->
        @.el = angular.element(".lightbox_confirm-delete")
        _.bindAll(@)

    hide: ->
        @.el.addClass("hidden")
        @.el.off(".confirm-dialog")

    ask: (title, subtitle) ->
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


module = angular.module("taigaBase")
module.service("$tgConfirm", ["$q", ConfirmService])
