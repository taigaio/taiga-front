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
# File: resources/importers-resource.service.coffee
###


taiga = @.taiga

TrelloResource = (urlsService, http) ->
    service = {}

    service.getAuthUrl = (url) ->
        url = urlsService.resolve("importers-trello-auth-url")
        return http.get(url)

    service.authorize = (verifyCode) ->
        url = urlsService.resolve("importers-trello-authorize")
        return http.post(url, {code: verifyCode})

    service.listProjects = (token) ->
        url = urlsService.resolve("importers-trello-list-projects")
        return http.post(url, {token: token}).then (response) -> Immutable.fromJS(response.data)

    service.listUsers = (token, projectId) ->
        url = urlsService.resolve("importers-trello-list-users")
        return http.post(url, {token: token, project: projectId}).then (response) -> Immutable.fromJS(response.data)

    service.importProject = (token, name, description, projectId, userBindings, keepExternalReference, isPrivate) ->
        url = urlsService.resolve("importers-trello-import-project")
        data = {
            token: token,
            name: name,
            description: description,
            project: projectId,
            users_bindings: userBindings.toJS(),
            keep_external_reference: keepExternalReference,
            is_private: isPrivate,
            template: "kanban",
        }
        return http.post(url, data)

    return () ->
        return {"trelloImporter": service}

TrelloResource.$inject = ["$tgUrls", "$tgHttp"]

JiraResource = (urlsService, http) ->
    service = {}

    service.getAuthUrl = (jira_url) ->
        url = urlsService.resolve("importers-jira-auth-url") + "?url=" + jira_url
        return http.get(url)

    service.authorize = (oauth_verifier) ->
        url = urlsService.resolve("importers-jira-authorize")
        return http.post(url, {oauth_verifier: oauth_verifier})

    service.listProjects = (jira_url, token) ->
        url = urlsService.resolve("importers-jira-list-projects")
        return http.post(url, {url: jira_url, token: token}).then (response) -> Immutable.fromJS(response.data)

    service.listUsers = (jira_url, token, projectId) ->
        url = urlsService.resolve("importers-jira-list-users")
        return http.post(url, {url: jira_url, token: token, project: projectId}).then (response) -> Immutable.fromJS(response.data)

    service.importProject = (jira_url, token, name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType, importerType) ->
        url = urlsService.resolve("importers-jira-import-project")
        projectTemplate = "kanban"
        if projectType != "kanban"
            projectTemplate = "scrum"

        data = {
            url: jira_url,
            token: token,
            name: name,
            description: description,
            project: projectId,
            users_bindings: userBindings.toJS(),
            keep_external_reference: keepExternalReference,
            is_private: isPrivate,
            project_type: projectType,
            importer_type: importerType,
            template: projectTemplate,
        }
        return http.post(url, data)

    return () ->
        return {"jiraImporter": service}

JiraResource.$inject = ["$tgUrls", "$tgHttp"]

GithubResource = (urlsService, http) ->
    service = {}

    service.getAuthUrl = (callbackUri) ->
        url = urlsService.resolve("importers-github-auth-url") + "?uri=" + callbackUri
        return http.get(url)

    service.authorize = (code) ->
        url = urlsService.resolve("importers-github-authorize")
        return http.post(url, {code: code})

    service.listProjects = (token) ->
        url = urlsService.resolve("importers-github-list-projects")
        return http.post(url, {token: token}).then (response) -> Immutable.fromJS(response.data)

    service.listUsers = (token, projectId) ->
        url = urlsService.resolve("importers-github-list-users")
        return http.post(url, {token: token, project: projectId}).then (response) -> Immutable.fromJS(response.data)

    service.importProject = (token, name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType) ->
        url = urlsService.resolve("importers-github-import-project")

        data = {
            token: token,
            name: name,
            description: description,
            project: projectId,
            users_bindings: userBindings.toJS(),
            keep_external_reference: keepExternalReference,
            is_private: isPrivate,
            template: projectType,
        }
        return http.post(url, data)

    return () ->
        return {"githubImporter": service}

GithubResource.$inject = ["$tgUrls", "$tgHttp"]

AsanaResource = (urlsService, http) ->
    service = {}

    service.getAuthUrl = () ->
        url = urlsService.resolve("importers-asana-auth-url")
        return http.get(url)

    service.authorize = (code) ->
        url = urlsService.resolve("importers-asana-authorize")
        return http.post(url, {code: code})

    service.listProjects = (token) ->
        url = urlsService.resolve("importers-asana-list-projects")
        return http.post(url, {token: token}).then (response) -> Immutable.fromJS(response.data)

    service.listUsers = (token, projectId) ->
        url = urlsService.resolve("importers-asana-list-users")
        return http.post(url, {token: token, project: projectId}).then (response) -> Immutable.fromJS(response.data)

    service.importProject = (token, name, description, projectId, userBindings, keepExternalReference, isPrivate, projectType) ->
        url = urlsService.resolve("importers-asana-import-project")

        data = {
            token: token,
            name: name,
            description: description,
            project: projectId,
            users_bindings: userBindings.toJS(),
            keep_external_reference: keepExternalReference,
            is_private: isPrivate,
            template: projectType,
        }
        return http.post(url, data)

    return () ->
        return {"asanaImporter": service}

AsanaResource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgTrelloImportResource", TrelloResource)
module.factory("tgJiraImportResource", JiraResource)
module.factory("tgGithubImportResource", GithubResource)
module.factory("tgAsanaImportResource", AsanaResource)
