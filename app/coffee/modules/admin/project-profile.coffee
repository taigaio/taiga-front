###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
        "tgAppMetaService",
        "$translate"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @navUrls,
                  @appMetaService, @translate) ->
        @scope.project = {}

        promise = @.loadInitialData()

        promise.then =>
            sectionName = @translate.instant( @scope.sectionName)
            title = @translate.instant("ADMIN.PROJECT_PROFILE.PAGE_TITLE", {
                     sectionName: sectionName, projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "project:loaded", =>
            sectionName = @translate.instant(@scope.sectionName)
            title = @translate.instant("ADMIN.PROJECT_PROFILE.PAGE_TITLE", {
                     sectionName: sectionName, projectName: @scope.project.name})
            description = @scope.project.description
            @appMetaService.setAll(title, description)

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            if not project.i_am_owner
                @location.path(@navUrls.resolve("permission-denied"))

            @scope.projectId = project.id
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
        promise = @.loadProject()
        return promise

    openDeleteLightbox: ->
        @rootscope.$broadcast("deletelightbox:new", @scope.project)

module.controller("ProjectProfileController", ProjectProfileController)


#############################################################################
## Project Profile Directive
#############################################################################

ProjectProfileDirective = ($repo, $confirm, $loading, $navurls, $location, projectService, currentUserService) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.save($scope.project)
            promise.then ->
                currentLoading.finish()
                $confirm.notify("success")
                newUrl = $navurls.resolve("project-admin-project-profile-details", {
                    project: $scope.project.slug
                })
                $location.path(newUrl)

                $ctrl.loadInitialData()

                projectService.fetchProject()
                currentUserService.loadProjects()

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

    return {link:link}

module.directive("tgProjectProfile", ["$tgRepo", "$tgConfirm", "$tgLoading", "$tgNavUrls", "$tgLocation",
                                      "tgProjectService", "tgCurrentUserService", ProjectProfileDirective])


#############################################################################
## Project Default Values Directive
#############################################################################

ProjectDefaultValuesDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = debounce 2000, (event) =>
            event.preventDefault()

            return if not form.validate()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.save($scope.project)
            promise.then ->
                currentLoading.finish()
                $confirm.notify("success")

            promise.then null, (data) ->
                currentLoading.finish()
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgProjectDefaultValues", ["$tgRepo", "$tgConfirm", "$tgLoading",
                                            ProjectDefaultValuesDirective])

#############################################################################
## Project Modules Directive
#############################################################################

ProjectModulesDirective = ($repo, $confirm, $loading, projectService) ->
    link = ($scope, $el, $attrs) ->
        submit = =>
            form = $el.find("form").checksley()
            return if not form.validate()

            target = angular.element(".admin-functionalities .submit-button")
            currentLoading = $loading()
                .target(target)
                .start()

            promise = $repo.save($scope.project)
            promise.then ->
                currentLoading.finish()
                $confirm.notify("success")
                $scope.$emit("project:loaded", $scope.project)

                projectService.fetchProject()

            promise.then null, (data) ->
                currentLoading.finish()
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
                $scope.project.videoconferences_extra_data = ""

        $scope.$watch "project", (project) ->
            if project.videoconferences?
                $scope.isVideoconferenceActivated = true
            else
                $scope.isVideoconferenceActivated = false

    return {link:link}

module.directive("tgProjectModules", ["$tgRepo", "$tgConfirm", "$tgLoading", "tgProjectService",
                                      ProjectModulesDirective])


#############################################################################
## Project Export Directive
#############################################################################

ProjectExportDirective = ($window, $rs, $confirm, $translate) ->
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


        loading_title = $translate.instant("ADMIN.PROJECT_EXPORT.LOADING_TITLE")
        loading_msg = $translate.instant("ADMIN.PROJECT_EXPORT.LOADING_MESSAGE")
        dump_ready_text = -> resultTitleEl.html($translate.instant("ADMIN.PROJECT_EXPORT.DUMP_READY"))
        asyn_message = -> resultTitleEl.html($translate.instant("ADMIN.PROJECT_EXPORT.ASYNC_MESSAGE"))
        syn_message = (url) -> resultTitleEl.html($translate.instant("ADMIN.PROJECT_EXPORT.SYNC_MESSAGE", {
                                                                                                   url: url}))

        setLoadingTitle = -> resultTitleEl.html(loading_title)
        setAsyncTitle = -> resultTitleEl.html(loading_msg)
        setSyncTitle = -> resultTitleEl.html(dump_ready_text)

        resultMessageEl = $el.find(".result-message ")
        setLoadingMessage = -> resultMessageEl.html(loading_msg)
        setAsyncMessage = -> resultMessageEl.html(asyn_message)
        setSyncMessage = (url) -> resultMessageEl.html(syn_message(url))

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

                errorMsg = $translate.instant("ADMIN.PROJECT_EXPORT.ERROR")

                if result.status == 429  # TOO MANY REQUESTS
                    errorMsg = $translate.instant("ADMIN.PROJECT_EXPORT.ERROR_BUSY")
                else if result.data?._error_message
                    errorMsg = $translate.instant("ADMIN.PROJECT_EXPORT.ERROR_BUSY", {
                                                   message: result.data._error_message})

                $confirm.notify("error", errorMsg)

            showLoadingMode()
            $rs.projects.export($scope.projectId).then(onSuccess, onError)

    return {link:link}

module.directive("tgProjectExport", ["$window", "$tgResources", "$tgConfirm", "$translate",
                                     ProjectExportDirective])


#############################################################################
## CSV Export Controllers
#############################################################################

class CsvExporterController extends taiga.Controller
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgUrls",
        "$tgConfirm",
        "$tgResources",
        "$translate"
    ]

    constructor: (@scope, @rootscope, @urls, @confirm, @rs, @translate) ->
        @rootscope.$on("project:loaded", @.setCsvUuid)
        @scope.$watch "csvUuid", (value) =>
            if value
                @scope.csvUrl = @urls.resolveAbsolute("#{@.type}-csv", value)
            else
                @scope.csvUrl = ""

    setCsvUuid: =>
        @scope.csvUuid = @scope.project["#{@.type}_csv_uuid"]

    _generateUuid: (response=null) =>
        promise = @rs.projects["regenerate_#{@.type}_csv_uuid"](@scope.projectId)

        promise.then (data) =>
            @scope.csvUuid = data.data?.uuid

        promise.then null, =>
            @confirm.notify("error")

        promise.finally ->
            response.finish() if response
        return promise

    regenerateUuid: ->
        if @scope.csvUuid
            title = @translate.instant("ADMIN.REPORTS.REGENERATE_TITLE")
            subtitle = @translate.instant("ADMIN.REPORTS.REGENERATE_SUBTITLE")

            @confirm.ask(title, subtitle).then @._generateUuid
        else
            @._generateUuid()


class CsvExporterUserstoriesController extends CsvExporterController
    type: "userstories"


class CsvExporterTasksController extends CsvExporterController
    type: "tasks"


class CsvExporterIssuesController extends CsvExporterController
    type: "issues"


module.controller("CsvExporterUserstoriesController", CsvExporterUserstoriesController)
module.controller("CsvExporterTasksController", CsvExporterTasksController)
module.controller("CsvExporterIssuesController", CsvExporterIssuesController)


#############################################################################
## CSV Directive
#############################################################################

CsvUsDirective = ($translate) ->
    link = ($scope) ->
        $scope.sectionTitle = "ADMIN.CSV.SECTION_TITLE_US"

    return {
        controller: "CsvExporterUserstoriesController",
        controllerAs: "ctrl",
        templateUrl: "admin/project-csv.html",
        link: link,
        scope: true
    }

module.directive("tgCsvUs", ["$translate", CsvUsDirective])


CsvTaskDirective = ($translate) ->
    link = ($scope) ->
        $scope.sectionTitle = "ADMIN.CSV.SECTION_TITLE_TASK"

    return {
        controller: "CsvExporterTasksController",
        controllerAs: "ctrl",
        templateUrl: "admin/project-csv.html",
        link: link,
        scope: true
    }

module.directive("tgCsvTask", ["$translate", CsvTaskDirective])


CsvIssueDirective = ($translate) ->
    link = ($scope) ->
        $scope.sectionTitle = "ADMIN.CSV.SECTION_TITLE_ISSUE"

    return {
        controller: "CsvExporterIssuesController",
        controllerAs: "ctrl",
        templateUrl: "admin/project-csv.html",
        link: link,
        scope: true
    }

module.directive("tgCsvIssue", ["$translate", CsvIssueDirective])


#############################################################################
## Project Logo Directive
#############################################################################

ProjectLogoDirective = ($auth, $model, $rs, $confirm) ->
    link = ($scope, $el, $attrs) ->
        showSizeInfo = ->
            $el.find(".size-info").addClass("active")

        onSuccess = (response) ->
            project = $model.make_model("projects", response.data)
            $scope.project = project

            $el.find('.loading-overlay').removeClass('active')
            $confirm.notify('success')

        onError = (response) ->
            showSizeInfo() if response.status == 413
            $el.find('.loading-overlay').removeClass('active')
            $confirm.notify('error', response.data._error_message)

        # Change photo
        $el.on "click", ".js-change-logo", ->
            $el.find("#logo-field").click()

        $el.on "change", "#logo-field", (event) ->
            if $scope.logoAttachment
                $el.find('.loading-overlay').addClass("active")
                $rs.projects.changeLogo($scope.project.id, $scope.logoAttachment).then(onSuccess, onError)

        # Use default photo
        $el.on "click", "a.js-use-default-logo", (event) ->
            $el.find('.loading-overlay').addClass("active")
            $rs.projects.removeLogo($scope.project.id).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgProjectLogo", ["$tgAuth", "$tgModel", "$tgResources", "$tgConfirm", ProjectLogoDirective])


#############################################################################
## Project Logo Model Directive
#############################################################################

ProjectLogoModelDirective = ($parse) ->
    link = ($scope, $el, $attrs) ->
        model = $parse($attrs.tgProjectLogoModel)
        modelSetter = model.assign

        $el.bind 'change', ->
            $scope.$apply ->
                modelSetter($scope, $el[0].files[0])

    return {link:link}

module.directive('tgProjectLogoModel', ['$parse', ProjectLogoModelDirective])
