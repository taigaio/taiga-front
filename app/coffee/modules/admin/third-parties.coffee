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
# File: modules/admin/third-parties.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
bindMethods = @.taiga.bindMethods
debounce = @.taiga.debounce

module = angular.module("taigaAdmin")


#############################################################################
## Github Controller
#############################################################################

class GithubController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$appTitle"
    ]

    constructor: (@scope, @repo, @rs, @params, @appTitle) ->
        bindMethods(@)

        @scope.sectionName = "Github" #i18n
        @scope.project = {}
        @scope.anyComputableRole = true

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Github - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "github").then (github) =>
            @scope.github = github

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.anyComputableRole = _.some(_.map(project.roles, (point) -> point.computable))

            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadModules())


module.controller("GithubController", GithubController)


#############################################################################
## Gitlab Controller
#############################################################################

class GitlabController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$appTitle"
    ]

    constructor: (@scope, @repo, @rs, @params, @appTitle) ->
        bindMethods(@)

        @scope.sectionName = "Gitlab" #i18n
        @scope.project = {}
        @scope.anyComputableRole = true

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Gitlab - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "project:modules:reload", =>
            @.loadModules()

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "gitlab").then (gitlab) =>
            @scope.gitlab = gitlab

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.anyComputableRole = _.some(_.map(project.roles, (point) -> point.computable))

            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadModules())


module.controller("GitlabController", GitlabController)


#############################################################################
## Bitbucket Controller
#############################################################################

class BitbucketController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$appTitle"
    ]

    constructor: (@scope, @repo, @rs, @params, @appTitle) ->
        bindMethods(@)

        @scope.sectionName = "Bitbucket" #i18n
        @scope.project = {}
        @scope.anyComputableRole = true

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Bitbucket - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "project:modules:reload", =>
            @.loadModules()

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "bitbucket").then (bitbucket) =>
            @scope.bitbucket = bitbucket

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.anyComputableRole = _.some(_.map(project.roles, (point) -> point.computable))

            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadModules())

module.controller("BitbucketController", BitbucketController)


SelectInputText =  ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", ".select-input-content", () ->
            $el.find("input").select()
            $el.find(".help-copy").addClass("visible")

    return {link:link}

module.directive("tgSelectInputText", SelectInputText)


#############################################################################
## GithubWebhooks Directive
#############################################################################

GithubWebhooksDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            $loading.start(submitButton)

            promise = $repo.saveAttribute($scope.github, "github")
            promise.then ->
                $loading.finish(submitButton)
                $confirm.notify("success")

            promise.then null, (data) ->
                $loading.finish(submitButton)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

    return {link:link}

module.directive("tgGithubWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", GithubWebhooksDirective])


#############################################################################
## GitlabWebhooks Directive
#############################################################################

GitlabWebhooksDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            $loading.start(submitButton)

            promise = $repo.saveAttribute($scope.gitlab, "gitlab")
            promise.then ->
                $loading.finish(submitButton)
                $confirm.notify("success")
                $scope.$emit("project:modules:reload")

            promise.then null, (data) ->
                $loading.finish(submitButton)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

    return {link:link}

module.directive("tgGitlabWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", GitlabWebhooksDirective])


#############################################################################
## BitbucketWebhooks Directive
#############################################################################

BitbucketWebhooksDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            $loading.start(submitButton)

            promise = $repo.saveAttribute($scope.bitbucket, "bitbucket")
            promise.then ->
                $loading.finish(submitButton)
                $confirm.notify("success")
                $scope.$emit("project:modules:reload")

            promise.then null, (data) ->
                $loading.finish(submitButton)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

    return {link:link}

module.directive("tgBitbucketWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", BitbucketWebhooksDirective])
