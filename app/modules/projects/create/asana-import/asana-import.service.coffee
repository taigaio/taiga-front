###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class AsanaImportService extends taiga.Service
    @.$inject = [
        'tgResources',
        '$location',
        '$q'
    ]

    constructor: (@resources, @location, @q) ->
        @.projects = Immutable.List()
        @.projectUsers = Immutable.List()
        @.token = null

    setToken: (token) ->
        @.token = token

    fetchProjects: () ->
        @resources.asanaImporter.listProjects(@.token).then (projects) => @.projects = projects

    fetchUsers: (projectId) ->
        @resources.asanaImporter.listUsers(@.token, projectId).then (users) => @.projectUsers = users

    importProject: (name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType) ->
        return @resources.asanaImporter.importProject(@.token, name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType)

    getAuthUrl: () ->
        return @q (resolve) =>
            @resources.asanaImporter.getAuthUrl().then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)

    authorize: (code) ->
        return @q (resolve, reject) =>
            @resources.asanaImporter.authorize(code).then ((response) =>
                @.token = response.data.token
                resolve(@.token)
            ), (error) ->
                reject(new Error(error.status))

angular.module("taigaProjects").service("tgAsanaImportService", AsanaImportService)
