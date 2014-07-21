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
## Project Values Controller
#############################################################################

class ProjectValuesController extends mixOf(taiga.Controller, taiga.PageMixin)
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
            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())


module.controller("ProjectValuesController", ProjectValuesController)

#############################################################################
## Project US Values Directive
#############################################################################

ProjectUsStatusDirective = ($log, $repo, $confirm, $location, $model) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        $scope.newUs = {
            "name": ""
            "is_closed": false
            "project": $scope.project.id
        }

        submit = =>
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

        $el.on "click", ".show-add-new", (event) ->
            event.preventDefault()
            $el.find(".new-us-status").css('display': 'flex')

        $el.on "click", ".add-new", (event) ->
            event.preventDefault()
            $scope.newUs.project = $scope.project.id
            $repo.create("userstory-statuses", $scope.newUs).then =>
                console.log "LOAD"
                $ctrl.loadProject()

        $el.on "click", ".delete-new", (event) ->
            event.preventDefault()
            $el.find(".new-us-status").hide()

        $el.on "click", ".delete-us-status", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            status = $model.make_model("userstory-statuses", target.scope().status)

            #TODO: i18n
            title = "Delete User Story status"
            subtitle = status.name
            $confirm.ask(title, subtitle).then =>
                $repo.remove(status).then =>
                    $ctrl.loadProject()

    return {link:link}

module.directive("tgProjectUsStatus", ["$log", "$tgRepo", "$tgConfirm", "$tgLocation", "$tgModel", ProjectUsStatusDirective])
