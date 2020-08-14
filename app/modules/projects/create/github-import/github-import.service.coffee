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
# File: projects/create/github-import/github-import.service.coffee
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
