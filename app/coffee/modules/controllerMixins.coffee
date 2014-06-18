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

class PageMixin
    loadUsersAndRoles: ->
        promise = @q.all([
            @rs.projects.usersList(@scope.projectId),
            @rs.projects.rolesList(@scope.projectId)
        ])

        return promise.then (results) =>
            [users, roles] = results

            @scope.users = _.sortBy(users, "id")
            @scope.roles = roles

            @scope.usersById = {}
            _.each(users, (x) => @scope.usersById[x.id] = x)

            availableRoles = _(@scope.project.memberships).map("role").uniq().value()
            @scope.computableRoles = _(roles).filter("computable")
                                             .filter((x) -> _.contains(availableRoles, x.id))
                                             .value()
            return results

taiga = @.taiga
taiga.PageMixin = PageMixin
