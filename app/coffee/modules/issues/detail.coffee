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
# File: modules/issues/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
trim = @.taiga.trim
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaIssues")

#############################################################################
## Issue Detail Controller
#############################################################################

class IssueDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        @scope.issueRef = @params.issueref
        @scope.sectionName = "Issues"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.issueStatusById = groupBy(project.issue_statuses, (x) -> x.id)
            @scope.severityById = groupBy(project.severities, (x) -> x.id)
            @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadIssue: ->
        return @rs.issues.get(@scope.projectId, @scope.issueId).then (issue) =>
            @scope.issue = issue
            return issue

    loadInitialData: ->
        params = {
            pslug: @params.pslug
            issueref: @params.issueref
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.issueId = data.issue
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadIssue())

module.controller("IssueDetailController", IssueDetailController)


#############################################################################
## Issue Main Directive
#############################################################################

IssueDirective = ($log, $location) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

    return {link:link}


module.directive("tgIssueDetail", ["$log", "$tgLocation", IssueDirective])


#############################################################################
## TagLine (possible should be moved as generic directive)
#############################################################################

TagLineDirective = ($log) ->
    template = _.template("""
    <% _.each(tags, function(tag) { %>
        <span class="tag"><%= tag.name %></span>
    <% }); %>""")

    renderTags = ($el, tags) ->
        tags = _.map(tags, (t) -> {name: t})
        html = template({tags: tags})
        $el.find("span.tags-container").html(html)

    normalizeTags = (tags) ->
        tags = _.map(tags, trim)
        tags = _.map(tags, (x) -> x.toLowerCase())
        return _.uniq(tags)

    link = ($scope, $el, $attrs, $model) ->
        $scope.$watch $attrs.ngModel, (val) ->
            return if not val
            renderTags($el, val)

        if $attrs.tgTagLine != "editable"
            $el.find("input").remove()

        $el.on "keyup", "input", (event) ->
            return if event.keyCode != 13
            target = angular.element(event.currentTarget)
            value = trim(target.val())

            if value.length <= 0
                return

            tags = _.clone($model.$modelValue, false)
            tags.push(value)

            target.val("")

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))


    return {link:link, require:"ngModel"}

module.directive("tgTagLine", ["$log", TagLineDirective])
