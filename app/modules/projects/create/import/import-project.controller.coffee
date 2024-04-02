###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class ImportProjectController
    @.$inject = [
        'tgTrelloImportService',
        'tgJiraImportService',
        'tgGithubImportService',
        'tgAsanaImportService',
        '$location',
        '$window',
        '$routeParams',
        '$tgNavUrls',
        '$tgConfig',
        '$tgConfirm',
        '$tgAnalytics',
    ]

    constructor: (@trelloService, @jiraService, @githubService, @asanaService,
                  @location, @window, @routeParams, @tgNavUrls, @config, @confirm,
                  @analytics) ->

    start: ->
        @.token = null
        @.from = @routeParams.platform

        locationSearch = @location.search()

        if @.from
            @analytics.trackEvent("import", @.from, "Start import from "+@.from, 1)

        if @.from == "asana"
            asanaOauthToken = locationSearch.code
            if locationSearch.code
                asanaOauthToken = locationSearch.code

                return @asanaService.authorize(asanaOauthToken).then ((token) =>
                    @location.search({token: encodeURIComponent(JSON.stringify(token))})
                ), @.cancelCurrentImport.bind(this)
            else
                @.token = JSON.parse(decodeURIComponent(locationSearch.token))
                @asanaService.setToken(@.token)

        if @.from  == 'trello'
            if locationSearch.oauth_verifier
                trelloOauthToken = locationSearch.oauth_verifier
                return @trelloService.authorize(trelloOauthToken).then ((token) =>
                    @location.search({token: token})
                ), @.cancelCurrentImport.bind(this)
            else if locationSearch.token
                @.token = locationSearch.token
                @trelloService.setToken(locationSearch.token)

        if @.from == "github"
            if locationSearch.code
                githubOauthToken = locationSearch.code

                return @githubService.authorize(githubOauthToken).then ((token) =>
                    @location.search({token: token})
                ), @.cancelCurrentImport.bind(this)
            else if locationSearch.token
                @.token = locationSearch.token
                @githubService.setToken(locationSearch.token)

        if @.from == "jira"
            jiraOauthToken = locationSearch.oauth_token

            if jiraOauthToken
                jiraOauthVerifier = locationSearch.oauth_verifier
                return @jiraService.authorize(jiraOauthVerifier).then ((data) =>
                    @location.search({token: data.token, url: data.url})
                ), @.cancelCurrentImport.bind(this)
            else
                @.token = locationSearch.token
                @jiraService.setToken(locationSearch.token, locationSearch.url)

    select: (from) ->
        if from == "trello"
            @trelloService.getAuthUrl().then (url) =>
                @window.open(url, "_self")
        else if from == "jira"
            @jiraService.getAuthUrl(@.jiraUrl).then (url) =>
                @window.open url, "_self"
            , (err) =>
                @confirm.notify('error', err)
        else if from == "github"
            callbackUri = @location.absUrl() + "/github"
            @githubService.getAuthUrl(callbackUri).then (url) =>
                @window.open(url, "_self")
        else if from == "asana"
            @asanaService.getAuthUrl().then (url) =>
                @window.open(url, "_self")
        else
            @.from = from

    unfoldOptions: (options) ->
        @.unfoldedOptions = options

    isActiveImporter: (importer) ->
        switch(importer)
            when "asana" then @config.get('enableAsanaImporter')
            when "github" then @config.get('enableGithubImporter')
            when "jira" then @config.get('enableJiraImporter')
            when "trello" then @config.get('enableTrelloImporter')
            else return false

    cancelCurrentImport: () ->
        @location.url(@tgNavUrls.resolve('create-project-import'))

    backToCreate: () ->
        @location.url(@tgNavUrls.resolve('create-project'))

angular.module("taigaProjects").controller("ImportProjectCtrl", ImportProjectController)
