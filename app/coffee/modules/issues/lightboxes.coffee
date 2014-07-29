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
# File: modules/issues/lightboxes.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaIssues")

#############################################################################
## Issue Create Lightbox Directive
#############################################################################

CreateIssueDirective = ($repo, $model, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()
        $scope.issue = {}

        $scope.$on "issueform:new", ->
            $el.removeClass("hidden")

            $scope.issue = {
                project: $scope.projectId
                subject: ""
                status: $scope.project.default_issue_status
                type: $scope.project.default_issue_type
                priority: $scope.project.default_priority
                severity: $scope.project.default_severity
                estimated_start: null
                estimated_finish: null
            }

        $scope.$on "$destroy", ->
            $el.off()

        submit = ->
            console.log $scope.issue
            if not form.validate()
                return

            promise = $repo.create("issues", $scope.issue)

            promise.then (data) ->
                $el.addClass("hidden")
                console.log "succcess", data
                $rootscope.$broadcast("issueform:new:success", data)

            # FIXME: error handling?
            promise.then null, ->
                console.log "FAIL"

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()
            submit()

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

    return {link:link}


CreateBulkIssuesDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, attrs) ->
        $scope.form = {data: "", usId: null}

        $scope.$on "issueform:bulk", (ctx, sprintId, usId)->
            $el.removeClass("hidden")
            $scope.form = {data: "", sprintId: sprintId, usId: usId}

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            data = $scope.form.data
            projectId = $scope.projectId

            promise = $rs.issues.bulkCreate(projectId, data)
            promise.then (result) ->
                $rootscope.$broadcast("issueform:bulk:success", result)
                $el.addClass("hidden")

            # TODO: error handling
            promise.then null, ->
                console.log "FAIL"

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateIssue", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    CreateIssueDirective
])

module.directive("tgLbCreateBulkIssues", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    CreateBulkIssuesDirective
])

#############################################################################
## Issue Create Lightbox Directive
#############################################################################

# BulkCreateIssuesDirective = ($repo, $model, $rs, $rootscope) ->
#     link = ($scope, $el, $attrs) ->
#         $scope.$on "issueform:new", ->
#             $el.removeClass("hidden")
#
#         $scope.$on "$destroy", ->
#             $el.off()
#
#         $el.on "click", ".close", (event) ->
#             event.preventDefault()
#             $el.addClass("hidden")
#
#     return {link:link}

# module.directive("tgLbCreateIssue", [
#     "$tgRepo",
#     "$tgModel",
#     "$tgResources",
#     "$rootScope",
#     CreateIssueDirective
# ])
