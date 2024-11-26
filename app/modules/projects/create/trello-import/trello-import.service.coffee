###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class TrelloImportService extends taiga.Service
    @.$inject = [
        'tgResources',
        '$q'
    ]

    constructor: (@resources, @q) ->
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
        return @q (resolve) =>
            @resources.trelloImporter.getAuthUrl().then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)

    authorize: (verifyCode) ->
        return @q (resolve, reject) =>
            @resources.trelloImporter.authorize(verifyCode).then ((response) =>
                @.token = response.data.token
                resolve(@.token)
            ), (error) ->
                reject(new Error(error.status))

angular.module("taigaProjects").service("tgTrelloImportService", TrelloImportService)
