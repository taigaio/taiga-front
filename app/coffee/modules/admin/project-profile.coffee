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
        "$location"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        @scope.project = {}

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.pointsList = _.sortBy(project.points, "order")
            @scope.usStatusList = _.sortBy(project.us_statuses, "order")
            @scope.taskStatusList = _.sortBy(project.task_statuses, "order")
            @scope.prioritiesList = _.sortBy(project.priorities, "order")
            @scope.severitiesList = _.sortBy(project.severities, "order")
            @scope.issueTypesList = _.sortBy(project.issue_types, "order")
            @scope.issueStatusList = _.sortBy(project.issue_statuses, "order")
            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())


module.controller("ProjectProfileController", ProjectProfileController)

#############################################################################
## Project Profile Directive
#############################################################################

ProjectProfileDirective = ($log, $repo, $confirm) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()
        submit = =>
            return if not form.validate()

            promise = $repo.save($scope.project)
            promise.then ->
                $confirm.notify("success")

            promise.then null, (data) ->
                console.log "FAIL"
                # TODO

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "form a.button-green", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

#############################################################################
## Project Features Directive
#############################################################################

ProjectFeaturesDirective = ($log, $repo, $confirm) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()
        submit = =>
            return if not form.validate()

            promise = $repo.save($scope.project)
            promise.then ->
                $confirm.notify("success")
                $scope.$emit("project:loaded", $scope.project)

            promise.then null, (data) ->
                console.log "FAIL"
                # TODO

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "form a.button-green", (event) ->
            event.preventDefault()
            submit()

        $scope.$watch "isVideoconferenceActivated", (isVideoconferenceActivated) ->
            if isVideoconferenceActivated
                $el.find(".videoconference-attributes").show()
            else
                $el.find(".videoconference-attributes").hide()
                $scope.project.videoconferences = null
                $scope.project.videoconferences_salt = ""

        $scope.$watch "project", (project) ->
            if project.videoconferences?
                $scope.isVideoconferenceActivated = true
            else
                $scope.isVideoconferenceActivated = false

    return {link:link}

module.directive("tgProjectProfile", ["$log", "$tgRepo", "$tgConfirm", ProjectProfileDirective])
module.directive("tgProjectFeatures", ["$log", "$tgRepo", "$tgConfirm", ProjectFeaturesDirective])
