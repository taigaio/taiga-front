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
            # @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
            # @scope.severityById = groupBy(project.severities, (x) -> x.id)
            # @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            # @scope.membersById = groupBy(project.memberships, (x) -> x.user)
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

ProjectProfileDirective = ($log) ->
    link = ($scope, $el, $attrs) ->
        $log.info "ProjectProfileDirective:link"

        form = $el.find("form").checksley()

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            $log.debug "ProjectProfileDirective:submit"

        $el.on "click", "form .a.button-green", (event) ->
            event.preventDefault()
            $log.debug "ProjectProfileDirective:submit a button"


    return {link:link}

module.directive("tgProjectProfile", ["$log", ProjectProfileDirective])
