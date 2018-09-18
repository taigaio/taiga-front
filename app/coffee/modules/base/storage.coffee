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
# File: modules/base/storage.coffee
###

taiga = @.taiga

class StorageService extends taiga.Service
    @.$inject = ["$rootScope"]

    constructor: ($rootScope) ->
        super()

    get: (key, _default) ->
        serializedValue = localStorage.getItem(key)
        if serializedValue == null
            return _default or null

        return JSON.parse(serializedValue)

    set: (key, val) ->
        if _.isObject(key)
            _.each key, (val, key) =>
                @set(key, val)
        else
            localStorage.setItem(key, JSON.stringify(val))

    contains: (key) ->
        value = @.get(key)
        return (value != null)

    remove: (key) ->
        localStorage.removeItem(key)

    clear: ->
        localStorage.clear()


module = angular.module("taigaBase")
module.service("$tgStorage", StorageService)
