###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
