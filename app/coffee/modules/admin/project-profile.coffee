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
# File: modules/admin/project-profile.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
trim = @.taiga.trim
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaAdmin")


#############################################################################
## Project Profile Controller
#############################################################################

class ProjectProfileController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$tgNavUrls",
        "$appTitle"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @navUrls, @appTitle) ->
        @scope.project = {}

        promise = @.loadInitialData()

        promise.then =>
            @appTitle.set("Project profile - " + @scope.sectionName + " - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "project:loaded", =>
            @appTitle.set("Project profile - " + @scope.sectionName + " - " + @scope.project.name)

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            if not project.i_am_owner
                @location.path(@navUrls.resolve("permission-denied"))

            @scope.project = project
            @scope.pointsList = _.sortBy(project.points, "order")
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")
            @scope.prioritiesList = _.sortBy(project.priorities, "order")
            @scope.severitiesList = _.sortBy(project.severities, "order")
            @scope.issueTypesList = _.sortBy(project.issue_types, "order")
            @scope.issueStatusList = _.sortBy(project.issue_statuses, "order")
            @scope.$emit('project:loaded', project)
            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())

    openDeleteLightbox: ->
        @rootscope.$broadcast("deletelightbox:new", @scope.project)

module.controller("ProjectProfileController", ProjectProfileController)


#############################################################################
## Project Profile Directive
#############################################################################

ProjectProfileDirective = ($repo, $confirm, $loading, $navurls, $location) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            $loading.start(submitButton)

            promise = $repo.save($scope.project)
            promise.then ->
                $loading.finish(submitButton)
                $confirm.notify("success")
                newUrl = $navurls.resolve("project-admin-project-profile-details", {project: $scope.project.slug})
                $location.path(newUrl)
                $scope.$emit("project:loaded", $scope.project)

            promise.then null, (data) ->
                $loading.finish(target)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

    return {link:link}

module.directive("tgProjectProfile", ["$tgRepo", "$tgConfirm", "$tgLoading", "$tgNavUrls", "$tgLocation", ProjectProfileDirective])

#############################################################################
## Project Default Values Directive
#############################################################################

ProjectDefaultValuesDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            $loading.start(submitButton)

            promise = $repo.save($scope.project)
            promise.then ->
                $loading.finish(submitButton)
                $confirm.notify("success")

            promise.then null, (data) ->
                $loading.finish(target)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgProjectDefaultValues", ["$tgRepo", "$tgConfirm", "$tgLoading", ProjectDefaultValuesDirective])

#############################################################################
## Project Modules Directive
#############################################################################

ProjectModulesDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()
        submit = =>
            return if not form.validate()
            target = angular.element(".admin-functionalities a.button-green")
            $loading.start(target)

            promise = $repo.save($scope.project)
            promise.then ->
                $loading.finish(target)
                $confirm.notify("success")
                $scope.$emit("project:loaded", $scope.project)

            promise.then null, (data) ->
                $loading.finish(target)
                $confirm.notify("error", data._error_message)

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", ".admin-functionalities a.button-green", (event) ->
            event.preventDefault()
            submit()

        $scope.$watch "isVideoconferenceActivated", (isVideoconferenceActivated) ->
            if isVideoconferenceActivated
                $el.find(".videoconference-attributes").removeClass("hidden")
            else
                $el.find(".videoconference-attributes").addClass("hidden")
                $scope.project.videoconferences = null
                $scope.project.videoconferences_salt = ""

        $scope.$watch "project", (project) ->
            if project.videoconferences?
                $scope.isVideoconferenceActivated = true
            else
                $scope.isVideoconferenceActivated = false

    return {link:link}

module.directive("tgProjectModules", ["$tgRepo", "$tgConfirm", "$tgLoading", ProjectModulesDirective])


#############################################################################
## Project Export Directive
#############################################################################

ProjectExportDirective = ($window, $rs, $confirm) ->
    link = ($scope, $el, $attrs) ->
        buttonsEl = $el.find(".admin-project-export-buttons")
        showButtons = -> buttonsEl.removeClass("hidden")
        hideButtons = -> buttonsEl.addClass("hidden")

        resultEl = $el.find(".admin-project-export-result")
        showResult = -> resultEl.removeClass("hidden")
        hideResult = -> resultEl.addClass("hidden")

        spinnerEl = $el.find(".spin")
        showSpinner = -> spinnerEl.removeClass("hidden")
        hideSpinner = -> spinnerEl.addClass("hidden")

        resultTitleEl = $el.find(".result-title")
        setLoadingTitle = -> resultTitleEl.html("We are generating your dump file") # TODO: i18n
        setAsyncTitle = -> resultTitleEl.html("We are generating your dump file") # TODO: i18n
        setSyncTitle = -> resultTitleEl.html("Your dump file is ready!") # TODO: i18n

        resultMessageEl = $el.find(".result-message ")
        setLoadingMessage = -> resultMessageEl.html("Please don't close this page.") # TODO: i18n
        setAsyncMessage = -> resultMessageEl.html("We will send you an email when ready.") # TODO: i18n
        setSyncMessage = (url) -> resultMessageEl.html("If the download doesn't start automatically click
                                                       <a href='#{url}' download title='Download
                                                       the dump file'>here.") # TODO: i18n

        showLoadingMode = ->
            showSpinner()
            setLoadingTitle()
            setLoadingMessage()
            hideButtons()
            showResult()

        showExportResultAsyncMode = ->
            hideSpinner()
            setAsyncTitle()
            setAsyncMessage()

        showExportResultSyncMode = (url) ->
            hideSpinner()
            setSyncTitle()
            setSyncMessage(url)

        showErrorMode = ->
            hideSpinner()
            hideResult()
            showButtons()

        $el.on "click", "a.button-export", debounce 2000, (event) =>
            event.preventDefault()

            onSuccess = (result) =>
                if result.status == 202 # Async mode
                    showExportResultAsyncMode()
                else #result.status == 200 # Sync mode
                    dumpUrl = result.data.url
                    showExportResultSyncMode(dumpUrl)
                    $window.open(dumpUrl, "_blank")

            onError = (result) =>
                showErrorMode()

                errorMsg = "Our oompa loompas have some problems generasting your dump.
                            Please try again. " # TODO: i18n

                if result.status == 429  # TOO MANY REQUESTS
                    errorMsg = "Sorry, our oompa loompas are very busy right now.
                                Please try again in a few minutes. " # TODO: i18n
                else if result.data?._error_message
                    errorMsg = "Our oompa loompas have some problems generasting your dump:
                                #{result.data._error_message}" # TODO: i18n

                $confirm.notify("error", errorMsg)

            showLoadingMode()
            $rs.projects.export($scope.projectId).then(onSuccess, onError)

    return {link:link}

module.directive("tgProjectExport", ["$window", "$tgResources", "$tgConfirm", ProjectExportDirective])
