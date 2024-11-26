###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class GithubImportService extends taiga.Service
    @.$inject = [
        'tgResources',
        '$q'
    ]

    constructor: (@resources, @q) ->
        @.projects = Immutable.List()
        @.projectUsers = Immutable.List()

    setToken: (token) ->
        @.token = token

    fetchProjects: () ->
        @resources.githubImporter.listProjects(@.token).then (projects) => @.projects = projects

    fetchUsers: (projectId) ->
        @resources.githubImporter.listUsers(@.token, projectId).then (users) => @.projectUsers = users

    importProject: (name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType) ->
        return @resources.githubImporter.importProject(@.token, name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType)

    getAuthUrl: (callbackUri) ->
        return @q (resolve) =>
            @resources.githubImporter.getAuthUrl(callbackUri).then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)

    authorize: (code) ->
        return @q (resolve, reject) =>
            @resources.githubImporter.authorize(code).then ((response) =>
                @.token = response.data.token
                resolve(@.token)
            ), (error) ->
                reject(new Error(error.status))

angular.module("taigaProjects").service("tgGithubImportService", GithubImportService)
