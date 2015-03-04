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
# File: modules/controllerMixins.coffee
###

taiga = @.taiga

groupBy = @.taiga.groupBy
joinStr = @.taiga.joinStr
trim = @.taiga.trim
toString = @.taiga.toString


#############################################################################
## Page Mixin
#############################################################################

class PageMixin
    fillUsersAndRoles: (users, roles) ->
        activeUsers = _.filter(users, (user) => user.is_active)
        @scope.activeUsers = _.sortBy(activeUsers, "full_name_display")
        @scope.activeUsersById = groupBy(@scope.activeUsers, (e) -> e.id)

        @scope.users = _.sortBy(users, "full_name_display")
        @scope.usersById = groupBy(@scope.users, (e) -> e.id)

        @scope.roles = _.sortBy(roles, "order")
        availableRoles = _(@scope.project.memberships).map("role").uniq().value()
        @scope.computableRoles = _(roles).filter("computable")
                                         .filter((x) -> _.contains(availableRoles, x.id))
                                         .value()
    loadUsersAndRoles: ->
        promise = @q.all([
            @rs.projects.usersList(@scope.projectId),
            @rs.projects.rolesList(@scope.projectId)
        ])

        return promise.then (results) =>
            [users, roles] = results
            @.fillUsersAndRoles(users, roles)
            return results

taiga.PageMixin = PageMixin


#############################################################################
## Filters Mixin
#############################################################################
# This mixin requires @location ($tgLocation), and @scope

class FiltersMixin
    selectFilter: (name, value, load=false) ->
        params = @location.search()
        if params[name] != undefined and name != "page"
            existing = _.map(taiga.toString(params[name]).split(","), (x) -> trim(x))
            existing.push(taiga.toString(value))
            existing = _.compact(existing)
            value = joinStr(",", _.uniq(existing))

        if !@location.isInCurrentRouteParams(name, value)
            location = if load then @location else @location.noreload(@scope)
            location.search(name, value)

    replaceFilter: (name, value, load=false) ->
        if !@location.isInCurrentRouteParams(name, value)
            location = if load then @location else @location.noreload(@scope)
            location.search(name, value)

    replaceAllFilters: (filters, load=false) ->
        location = if load then @location else @location.noreload(@scope)
        location.search(filters)

    unselectFilter: (name, value, load=false) ->
        params = @location.search()

        if params[name] is undefined
            return

        if value is undefined or value is null
            delete params[name]

        parsedValues = _.map(taiga.toString(params[name]).split(","), (x) -> trim(x))
        newValues = _.reject(parsedValues, (x) -> x == taiga.toString(value))
        newValues = _.compact(newValues)

        if _.isEmpty(newValues)
            value = null
        else
            value = joinStr(",", _.uniq(newValues))

        location = if load then @location else @location.noreload(@scope)
        location.search(name, value)

taiga.FiltersMixin = FiltersMixin
