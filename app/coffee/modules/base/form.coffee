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
# File: modules/base/form.coffee
###

taiga = @.taiga

# Valiation in taiga is performed in two different ways: using
# this directive, and using checksley directly.
# This directive should be used when the form is controlled by
# controller, and checksley should be used directly when form
# is controlled by an other directive.

# TODO: unfinished, should be finished when it really needed

TaigaFormDirective = ->
    link = ($scope, $el, $attrs) ->
        if not $el.is("form")
            throw new Error("tg-form can only be used on form label")

        form = $el.checksley()

        $el.on "submit", (event) ->
            console.log "NORMAL SUBMIT", event
            event.preventDefault()

        $el.on "click", "input[type=submit]", (event) ->
            console.log "SUBMIT BUTTON CLICKED", event
            if form.validate()
                $scope.$eval($attrs.tgForm)

        attachChecksley = ->
            form.destroy()
            form.initialize()

        $scope.$on("$includeContentLoaded", attachChecksley)
        $scope.$on("form:reset", attachChecksley)

        $scope.$on "form:errors", (errors) ->
            if not _.isEmpty(errors)
                form.setErrors(errors)

    return {link:link}

module = angular.module("taigaBase")
module.directive("tgForm", TaigaFormDirective)
