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
# File: modules/common/filters.coffee
###

taiga = @.taiga

module = angular.module("taigaCommon")


defaultFilter = ->
    return (value, defaultValue) ->
        if value is [null, undefined]
            return defaultValue
        return value

module.filter("default", defaultFilter)


yesNoFilter = ($translate) ->
    return (value) ->
        if value
            return $translate.instant("COMMON.YES")

        return $translate.instant("COMMON.NO")

module.filter("yesNo", ["$translate", yesNoFilter])


unslugify = ->
    return taiga.unslugify

module.filter("unslugify", unslugify)


momentFormat = ->
    return (input, format) ->
        if input
            return moment(input).format(format)
        return ""

module.filter("momentFormat", momentFormat)


momentFromNow = ->
    return (input, without_suffix) ->
        if input
            return moment(input).fromNow(without_suffix or false)
        return ""

module.filter("momentFromNow", momentFromNow)
