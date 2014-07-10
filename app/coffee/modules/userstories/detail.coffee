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
# File: modules/userstories/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy

module = angular.module("taigaUserStories")

#############################################################################
## User story Detail Controller
#############################################################################

class UserStoryDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        @scope.sectionName = "User Story"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.statusList = project.issue_statuses
            @scope.statusById = groupBy(project.us_statuses, (x) -> x.id)
            @scope.severityList = project.severities
            @scope.severityById = groupBy(project.severities, (x) -> x.id)
            @scope.priorityList = project.priorities
            @scope.priorityById = groupBy(project.priorities, (x) -> x.id)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadUs: ->
        return @rs.userstories.get(@scope.projectId, @scope.usId).then (us) =>
            @scope.us = us
            @scope.commentModel = us            
            @scope.previousUrl = "/project/#{@scope.project.slug}/us/#{@scope.us.neighbors.previous.ref}" if @scope.us.neighbors.previous.id?
            @scope.nextUrl = "/project/#{@scope.project.slug}/us/#{@scope.us.neighbors.next.ref}" if @scope.us.neighbors.next.id?

    loadHistory: ->
        return @rs.userstories.history(@scope.usId).then (history) =>
            _.each history.results, (historyResult) ->
                #If description was modified take only the description_html field
                if historyResult.values_diff.description?
                    historyResult.values_diff.description = historyResult.values_diff.description_html
                    delete historyResult.values_diff.description_html
                    delete historyResult.values_diff.description_diff

            @scope.history = history.results
            @scope.comments = _.filter(history.results, (historyEntry) -> historyEntry.comment != "")

    loadInitialData: ->
        params = {
            pslug: @params.pslug
            usref: @params.usref
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.projectId = data.project
            @scope.usId = data.us
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadUs())
                      .then(=> @.loadHistory())

module.controller("UserStoryDetailController", UserStoryDetailController)



#############################################################################
## User story Main Directive
#############################################################################

UsDirective = ($tgrepo, $log, $location, $confirm) ->
    linkSidebar = ($scope, $el, $attrs, $ctrl) ->

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkSidebar($scope, $el, $attrs, $ctrl)

        $el.on "click", ".save-us", (event) ->
            $tgrepo.save($scope.us).then ->
                $confirm.notify("success")
                $location.path("/project/#{$scope.project.slug}/us/#{$scope.us.ref}")

        $el.on "click", ".add-comment a.button-green", (event) ->
            event.preventDefault()
            $tgrepo.save($scope.us).then ->
                $ctrl.loadHistory()

        $el.on "click", ".us-activity-tabs li a", (event) ->
            $el.find(".us-activity-tabs li a").toggleClass("active")
            $el.find(".us-activity section").toggleClass("hidden")

    return {link:link}

module.directive("tgUsDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", UsDirective])


#############################################################################
## User story status directive
#############################################################################

UsStatusDetailDirective = () ->
    #TODO: i18n
    template = _.template("""
        <h1>
            <span>
            <% if (status.is_closed) { %>
            Closed
            <% } else { %>
            Open
            <% } %>
            <span class="us-detail-status"><%= status.name %></span>
        </h1>
        <div class="issue-data">
            <div class="status-data <% if (editable) { %>clickable<% } %>">
                <span class="level" style="background-color:<%= status.color %>"></span>
                <span class="status-status"><%= status.name %></span>
                <span class="level-name">status</span>
            </div>
        </div>
    """)
    selectionStatusTemplate = _.template("""
      <ul class="popover pop-status">
          <% _.each(statuses, function(status) { %>
          <li><a href="" class="status" title="<%- status.name %>"
                 data-status-id="<%- status.id %>"><%- status.name %></a></li>
          <% }); %>
      </ul>
    """)

    link = ($scope, $el, $attrs, $model) ->
        editable = $attrs.editable?

        renderUsstatus = (us) ->
            status = $scope.statusById[us.status]
            html = template({
                editable: editable
                status: status
            })
            $el.html(html)
            $el.find(".status-data").append(selectionStatusTemplate({statuses:$scope.statusList}))

        $scope.$watch $attrs.ngModel, (us) ->
            if us?
                renderUsstatus(us)

        if editable
            $el.on "click", ".status-data", (event) ->
                event.preventDefault()
                event.stopPropagation()
                $el.find(".pop-status").show()
                body = angular.element("body")
                body.one "click", (event) ->
                    $el.find(".popover").hide()

            $el.on "click", ".status", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                $model.$modelValue.status = target.data("status-id")
                renderUsstatus($model.$modelValue)
                $el.find(".popover").hide()

    return {link:link, require:"ngModel"}

module.directive("tgUsStatusDetail", UsStatusDetailDirective)
