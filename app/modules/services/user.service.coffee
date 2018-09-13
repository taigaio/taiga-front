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
# File: services/user.service.coffee
###

taiga = @.taiga
bindMethods = taiga.bindMethods


class UserService extends taiga.Service
    @.$inject = ["tgResources"]

    constructor: (@rs) ->
        bindMethods(@)

    getUserByUserName: (username) ->
        return @rs.users.getUserByUsername(username)

    getContacts: (userId, excludeProjectId) ->
        return @rs.users.getContacts(userId, excludeProjectId)

    getLiked: (userId, pageNumber, objectType, textQuery) ->
        return @rs.users.getLiked(userId, pageNumber, objectType, textQuery)

    getVoted: (userId, pageNumber, objectType, textQuery) ->
        return @rs.users.getVoted(userId, pageNumber, objectType, textQuery)

    getWatched: (userId, pageNumber, objectType, textQuery) ->
        return @rs.users.getWatched(userId, pageNumber, objectType, textQuery)

    getStats: (userId) ->
        return @rs.users.getStats(userId)

    attachUserContactsToProjects: (userId, projects) ->
        return @.getContacts(userId)
            .then (contacts) ->
                projects = projects.map (project) ->
                    contactsFiltered = contacts.filter (contact) ->
                        contactId = contact.get("id")
                        return project.get('members').indexOf(contactId) != -1

                    project = project.set("contacts", contactsFiltered)

                    return project

                return projects

angular.module("taigaCommon").service("tgUserService", UserService)
