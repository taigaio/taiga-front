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


class PageMixin
    loadUsersAndRoles: ->
        promise = @q.all([
            @rs.projects.usersList(@scope.projectId),
            @rs.projects.rolesList(@scope.projectId)
        ])

        return promise.then (results) =>
            [users, roles] = results

            @scope.users = _.sortBy(users, "full_name")
            @scope.usersById = groupBy(@scope.users, (e) -> e.id)

            @scope.roles = _.sortBy(roles, "order")
            availableRoles = _(@scope.project.memberships).map("role").uniq().value()
            @scope.computableRoles = _(roles).filter("computable")
                                             .filter((x) -> _.contains(availableRoles, x.id))
                                             .value()

            return results


# This mixin requires @location and @scope

class FiltersMixin
    selectFilter: (name, value, load=false) ->
        params = @location.search()
        if params[name] != undefined and name != "page"
            existing = _.map(params[name].split(","), trim)
            existing.push(value)

            value = joinStr(",", _.uniq(existing))

        location = if load then @location else @location.noreload(@scope)
        location.search(name, value)

    unselectFilter: (name, value, load=false) ->
        params = @location.search()

        if params[name] is undefined
            return

        if value is undefined or value is null
            delete params[name]

        parsedValues = _.map(params[name].split(","), trim)
        newValues = _.reject(parsedValues, (x) -> x == toString(value))

        if _.isEmpty(newValues)
            value = null
        else
            value = joinStr(",", _.uniq(newValues))

        location = if load then @location else @location.noreload(@scope)
        location.search(name, value)


taiga = @.taiga
taiga.PageMixin = PageMixin
taiga.FiltersMixin = FiltersMixin
