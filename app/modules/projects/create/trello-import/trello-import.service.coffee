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
# File: projects/create/trello-import/trello-import.service.coffee
###

class TrelloImportService extends taiga.Service
    @.$inject = [
        'tgResources'
    ]

    constructor: (@resources) ->
        @.projects = Immutable.List()
        @.projectUsers = Immutable.List()
        @.token = null

    setToken: (token) ->
        @.token = token

    fetchProjects: () ->
        @resources.trelloImporter.listProjects(@.token).then (projects) => @.projects = projects

    fetchUsers: (projectId) ->
        @resources.trelloImporter.listUsers(@.token, projectId).then (users) => @.projectUsers = users

    importProject: (name, description, projectId, userBindings, keepExternalReference, isPrivate) ->
        return @resources.trelloImporter.importProject(@.token, name, description, projectId, userBindings, keepExternalReference, isPrivate)

    getAuthUrl: () ->
        return new Promise (resolve) =>
            @resources.trelloImporter.getAuthUrl().then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)

    authorize: (verifyCode) ->
        return new Promise (resolve, reject) =>
            @resources.trelloImporter.authorize(verifyCode).then ((response) =>
                @.token = response.data.token
                resolve(@.token)
            ), (error) ->
                reject(new Error(error.status))

angular.module("taigaProjects").service("tgTrelloImportService", TrelloImportService)
