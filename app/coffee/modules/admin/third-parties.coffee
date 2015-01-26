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
timeout = @.taiga.timeout

module = angular.module("taigaAdmin")

#############################################################################
## Webhooks
#############################################################################

class WebhooksController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$appTitle"
    ]

    constructor: (@scope, @repo, @rs, @params, @appTitle) ->
        bindMethods(@)

        @scope.sectionName = "Webhooks" #i18n
        @scope.project = {}

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Webhooks - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "webhooks:reload", @.loadWebhooks

    loadWebhooks: ->
        return @rs.webhooks.list(@scope.projectId).then (webhooks) =>
            @scope.webhooks = webhooks

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadWebhooks())

module.controller("WebhooksController", WebhooksController)

#############################################################################
## Webhook Directive
#############################################################################

WebhookDirective = ($rs, $repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        webhook = $scope.$eval($attrs.tgWebhook)

        updateLogs = () ->
            $rs.webhooklogs.list(webhook.id).then (webhooklogs) =>
                webhooklogs = webhooklogs.reverse()
                for  log in webhooklogs
                    statusText = String(log.status)
                    log.validStatus = statusText.length==3 and statusText[0]="2"
                    log.prettySentData = JSON.stringify(log.request_data.data, undefined, 2)
                    log.prettySentHeaders = JSON.stringify(log.request_headers, undefined, 2)
                    log.prettyDate = moment(log.created).format("DD MMM YYYY [at] hh:mm:ss")

                webhook.logs_counter = webhooklogs.length
                webhook.logs = webhooklogs
                updateShowHideHistoryText()

        updateShowHideHistoryText = () ->
            textElement = $el.find(".toggle-history")
            historyElement = textElement.parents(".single-webhook-wrapper").find(".webhooks-history")
            if historyElement.hasClass("open")
                textElement.text("(Hide history)")
            else
                textElement.text("(Show history)")

        showVisualizationMode = () ->
            $el.find(".edition-mode").addClass("hidden")
            $el.find(".visualization-mode").removeClass("hidden")

        showEditMode = () ->
            $el.find(".visualization-mode").addClass("hidden")
            $el.find(".edition-mode").removeClass("hidden")

        openHistory = () ->
            $el.find(".webhooks-history").addClass("open")

        cancel = () ->
            showVisualizationMode()
            $scope.$apply ->
                webhook.revert()

        save = debounce 2000, (target) ->
            form = target.parents("form").checksley()
            return if not form.validate()

            value = target.scope().value
            promise = $repo.save(webhook)
            promise.then =>
                showVisualizationMode()

            promise.then null, (data) ->
                $confirm.notify("error")
                form.setErrors(data)

        $el.on "click", ".test-webhook", () ->
            openHistory()
            $rs.webhooks.test(webhook.id).then =>
                updateLogs()

        $el.on "click", ".edit-webhook", () ->
            showEditMode()

        $el.on "click", ".cancel-existing", () ->
            cancel()

        $el.on "click", ".edit-existing", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            save(target)

        $el.on "keyup", ".edition-mode input", (event) ->
            if event.keyCode == 13
                target = angular.element(event.currentTarget)
                saveWebhook(target)
            else if event.keyCode == 27
                target = angular.element(event.currentTarget)
                cancel(target)

        $el.on "click", ".delete-webhook", () ->
            title = "Delete webhook"  #TODO: i18in
            message = "Webhook '#{webhook.name}'" #TODO: i18in

            $confirm.askOnDelete(title, message).then (finish) =>
                onSucces = ->
                    finish()
                    $scope.$emit("webhooks:reload")

                onError = ->
                    finish(false)
                    $confirm.notify("error")

                $repo.remove(webhook).then(onSucces, onError)

        $el.on "click", ".toggle-history", (event) ->
            target = angular.element(event.currentTarget)
            if not webhook.logs? or webhook.logs.length == 0
                updateLogs().then ->
                    #Waiting for ng-repeat to finish
                    timeout 0, ->
                        $el.find(".webhooks-history").toggleClass("open")
                        updateShowHideHistoryText()

            else
                $el.find(".webhooks-history").toggleClass("open")
                $scope.$apply () ->
                    updateShowHideHistoryText()


        $el.on "click", ".history-single", (event) ->
            target = angular.element(event.currentTarget)
            target.toggleClass("history-single-open")
            target.siblings(".history-single-response").toggleClass("open")

        $el.on "click", ".resend-request", (event) ->
            target = angular.element(event.currentTarget)
            log = target.data("log")
            $rs.webhooklogs.resend(log).then () =>
                updateLogs()

    return {link:link}

module.directive("tgWebhook", ["$tgResources", "$tgRepo", "$tgConfirm", "$tgLoading", WebhookDirective])


#############################################################################
## New webhook Directive
#############################################################################

NewWebhookDirective = ($rs, $repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        webhook = $scope.$eval($attrs.tgWebhook)
        formDOMNode = $el.find(".new-webhook-form")
        addWebhookDOMNode = $el.find(".add-webhook")
        initializeNewValue = ->
            $scope.newValue = {
                "name": ""
                "url": ""
                "key": ""
            }

        initializeNewValue()

        $scope.$watch "webhooks", (webhooks) ->
            if webhooks?
                if webhooks.length == 0
                    formDOMNode.removeClass("hidden")
                    addWebhookDOMNode.addClass("hidden")
                    formDOMNode.find("input")[0].focus()
                else
                    formDOMNode.addClass("hidden")
                    addWebhookDOMNode.removeClass("hidden")

        formDOMNode.on "click", ".add-new", debounce 2000, (event) ->
            event.preventDefault()
            form = formDOMNode.checksley()
            return if not form.validate()

            $scope.newValue.project = $scope.project.id
            promise = $repo.create("webhooks", $scope.newValue)
            promise.then =>
                $scope.$emit("webhooks:reload")
                initializeNewValue()

            promise.then null, (data) ->
                $confirm.notify("error")
                form.setErrors(data)

        formDOMNode.on "click", ".cancel-new", (event) ->
            $scope.$apply ->
                initializeNewValue()

        addWebhookDOMNode.on "click", (event) ->
            formDOMNode.removeClass("hidden")
            formDOMNode.find("input")[0].focus()

    return {link:link}

module.directive("tgNewWebhook", ["$tgResources", "$tgRepo", "$tgConfirm", "$tgLoading", NewWebhookDirective])


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


#############################################################################
## Valid Origin IP's Directive
#############################################################################
ValidOriginIpsDirective = ->
    link = ($scope, $el, $attrs, $ngModel) ->
      $ngModel.$parsers.push (value) ->
          value = $.trim(value)
          if value == ""
              return []

          return value.split(",")

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgValidOriginIps", ValidOriginIpsDirective)
