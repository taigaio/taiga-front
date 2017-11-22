###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
        "$tgLocation",
        "$tgNavUrls",
        "tgAppMetaService",
        "$translate",
        "tgErrorHandlingService",
        "tgProjectService"
    ]

    constructor: (@scope, @repo, @rs, @params, @location, @navUrls, @appMetaService, @translate, @errorHandlingService, @projectService) ->
        bindMethods(@)

        @scope.sectionName = "ADMIN.WEBHOOKS.SECTION_NAME"
        @scope.project = {}

        promise = @.loadInitialData()

        promise.then () =>
            title = @translate.instant("ADMIN.WEBHOOKS.PAGE_TITLE", {projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "webhooks:reload", @.loadWebhooks

    loadWebhooks: ->
        return @rs.webhooks.list(@scope.projectId).then (webhooks) =>
            @scope.webhooks = webhooks

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.i_am_admin
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        return project

    loadInitialData: ->
        @.loadProject()

        return @.loadWebhooks()

module.controller("WebhooksController", WebhooksController)


#############################################################################
## Webhook Directive
#############################################################################

WebhookDirective = ($rs, $repo, $confirm, $loading, $translate) ->
    link = ($scope, $el, $attrs) ->
        webhook = $scope.$eval($attrs.tgWebhook)

        updateLogs = () ->
            prettyDate = $translate.instant("ADMIN.WEBHOOKS.DATE")

            $rs.webhooklogs.list(webhook.id).then (webhooklogs) =>
                for log in webhooklogs
                    log.validStatus = 200 <= log.status < 300
                    log.prettySentHeaders = _.map(_.toPairs(log.request_headers), ([header, value]) -> "#{header}: #{value}").join("\n")
                    log.prettySentData = JSON.stringify(log.request_data)
                    log.prettyDate = moment(log.created).format(prettyDate)

                webhook.logs_counter = webhooklogs.length
                webhook.logs = webhooklogs
                updateShowHideHistoryText()

        updateShowHideHistoryText = () ->
            textElement = $el.find(".toggle-history")
            historyElement = textElement.parents(".single-webhook-wrapper").find(".webhooks-history")

            if historyElement.hasClass("open")
                text = $translate.instant("ADMIN.WEBHOOKS.ACTION_HIDE_HISTORY")
                title = $translate.instant("ADMIN.WEBHOOKS.ACTION_HIDE_HISTORY_TITLE")
            else
                text = $translate.instant("ADMIN.WEBHOOKS.ACTION_SHOW_HISTORY")
                title = $translate.instant("ADMIN.WEBHOOKS.ACTION_SHOW_HISTORY_TITLE")

            textElement.text(text)
            textElement.prop("title", title)

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
                save(target)
            else if event.keyCode == 27
                target = angular.element(event.currentTarget)
                cancel(target)

        $el.on "click", ".delete-webhook", () ->
            title = $translate.instant("ADMIN.WEBHOOKS.DELETE")
            message = $translate.instant("ADMIN.WEBHOOKS.WEBHOOK_NAME", {name: webhook.name})

            $confirm.askOnDelete(title, message).then (askResponse) =>
                onSucces = ->
                    askResponse.finish()
                    $scope.$emit("webhooks:reload")

                onError = ->
                    askResponse.finish(false)
                    $confirm.notify("error")

                $repo.remove(webhook).then(onSucces, onError)

        $el.on "click", ".toggle-history", (event) ->
            target = angular.element(event.currentTarget)

            if not webhook.logs? or webhook.logs.length == 0
                updateLogs().then ->
                    #Waiting for ng-repeat to finish
                    timeout 0, ->
                        $el.find(".webhooks-history")
                            .toggleClass("open")
                            .slideToggle()

                        updateShowHideHistoryText()

            else
                $el.find(".webhooks-history")
                    .toggleClass("open")
                    .slideToggle()

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

module.directive("tgWebhook", ["$tgResources", "$tgRepo", "$tgConfirm", "$tgLoading", "$translate",
                               WebhookDirective])


#############################################################################
## New webhook Directive
#############################################################################

NewWebhookDirective = ($rs, $repo, $confirm, $loading, $analytics) ->
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

        save = debounce 2000, () ->
            form = formDOMNode.checksley()
            return if not form.validate()

            $scope.newValue.project = $scope.project.id
            promise = $repo.create("webhooks", $scope.newValue)
            promise.then =>
                $analytics.trackEvent("webhooks", "create", "Create new webhook", 1)
                $scope.$emit("webhooks:reload")
                initializeNewValue()

            promise.then null, (data) ->
                $confirm.notify("error")
                form.setErrors(data)

        formDOMNode.on "click", ".add-new", (event) ->
            event.preventDefault()
            save()

        formDOMNode.on "keyup", "input", (event) ->
            if event.keyCode == 13
                save()

        formDOMNode.on "click", ".cancel-new", (event) ->
            $scope.$apply ->
                initializeNewValue()

                # Close form if there some webhooks created
                if $scope.webhooks.length >= 1
                    formDOMNode.addClass("hidden")

        addWebhookDOMNode.on "click", (event) ->
            formDOMNode.removeClass("hidden")
            formDOMNode.find("input")[0].focus()

    return {link:link}

module.directive("tgNewWebhook", ["$tgResources", "$tgRepo", "$tgConfirm", "$tgLoading", "$tgAnalytics", NewWebhookDirective])


#############################################################################
## Github Controller
#############################################################################

class GithubController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "tgAppMetaService",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@scope, @repo, @rs, @params, @appMetaService, @translate, @projectService) ->
        bindMethods(@)

        @scope.sectionName = @translate.instant("ADMIN.GITHUB.SECTION_NAME")
        @scope.project = {}

        promise = @.loadInitialData()

        promise.then () =>
            title = @translate.instant("ADMIN.GITHUB.PAGE_TITLE", {projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "github").then (github) =>
            @scope.github = github

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        return project

    loadInitialData: ->
        promise = @.loadProject()
        return @.loadModules()

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
        "tgAppMetaService",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@scope, @repo, @rs, @params, @appMetaService, @translate, @projectService) ->
        bindMethods(@)

        @scope.sectionName = @translate.instant("ADMIN.GITLAB.SECTION_NAME")
        @scope.project = {}
        promise = @.loadInitialData()

        promise.then () =>
            title = @translate.instant("ADMIN.GITLAB.PAGE_TITLE", {projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "project:modules:reload", =>
            @.loadModules()

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "gitlab").then (gitlab) =>
            @scope.gitlab = gitlab

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        return project

    loadInitialData: ->
        @.loadProject()
        return @.loadModules()

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
        "tgAppMetaService",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@scope, @repo, @rs, @params, @appMetaService, @translate, @projectService) ->
        bindMethods(@)

        @scope.sectionName = @translate.instant("ADMIN.BITBUCKET.SECTION_NAME")
        @scope.project = {}
        promise = @.loadInitialData()

        promise.then () =>
            title = @translate.instant("ADMIN.BITBUCKET.PAGE_TITLE", {projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "project:modules:reload", =>
            @.loadModules()

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "bitbucket").then (bitbucket) =>
            @scope.bitbucket = bitbucket

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        return project

    loadInitialData: ->
        @.loadProject()
        return @.loadModules()

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

GithubWebhooksDirective = ($repo, $confirm, $loading, $analytics) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.saveAttribute($scope.github, "github")
            promise.then ->
                $analytics.trackEvent("github-webhook", "created-or-changed", "Create or changed github webhook", 1)
                currentLoading.finish()
                $confirm.notify("success")

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

    return {link:link}

module.directive("tgGithubWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", "$tgAnalytics", GithubWebhooksDirective])


#############################################################################
## GitlabWebhooks Directive
#############################################################################

GitlabWebhooksDirective = ($repo, $confirm, $loading, $analytics) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.saveAttribute($scope.gitlab, "gitlab")
            promise.then ->
                $analytics.trackEvent("gitlab-webhook", "created-or-changed", "Create or changed gitlab webhook", 1)
                currentLoading.finish()
                $confirm.notify("success")
                $scope.$emit("project:modules:reload")

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

    return {link:link}

module.directive("tgGitlabWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", "$tgAnalytics", GitlabWebhooksDirective])


#############################################################################
## BitbucketWebhooks Directive
#############################################################################

BitbucketWebhooksDirective = ($repo, $confirm, $loading, $analytics) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.saveAttribute($scope.bitbucket, "bitbucket")
            promise.then ->
                $analytics.trackEvent("bitbucket-webhook", "created-or-changed", "Create or changed bitbucket webhook", 1)
                currentLoading.finish()
                $confirm.notify("success")
                $scope.$emit("project:modules:reload")

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

    return {link:link}

module.directive("tgBitbucketWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", "$tgAnalytics", BitbucketWebhooksDirective])


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

#############################################################################
## Gogs Controller
#############################################################################

class GogsController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "tgAppMetaService",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@scope, @repo, @rs, @params, @appMetaService, @translate, @projectService) ->
        bindMethods(@)

        @scope.sectionName = @translate.instant("ADMIN.GOGS.SECTION_NAME")
        @scope.project = {}

        promise = @.loadInitialData()

        promise.then () =>
            title = @translate.instant("ADMIN.GOGS.PAGE_TITLE", {projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "gogs").then (gogs) =>
            @scope.gogs = gogs

    loadProject: ->
        project = @projectService.project.toJS()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        return project

    loadInitialData: ->
        @.loadProject()
        return @.loadModules()

GogsWebhooksDirective = ($repo, $confirm, $loading, $analytics) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.saveAttribute($scope.gogs, "gogs")
            promise.then ->
                $analytics.trackEvent("gogs-webhook", "create-or-change", "Create or change gogs webhook", 1)
                currentLoading.finish()
                $confirm.notify("success")
                $scope.$emit("project:modules:reload")

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

    return {link:link}

module.controller("GogsController", GogsController)
module.directive("tgGogsWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", "$tgAnalytics", GogsWebhooksDirective])
