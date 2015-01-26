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
# File: modules/team/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

module = angular.module("taigaTeam")

#############################################################################
## Team Controller
#############################################################################

class TeamController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$q",
        "$location",
        "$tgNavUrls",
        "$appTitle",
        "$tgAuth",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @rs, @params, @q, @location, @navUrls, @appTitle, @auth, tgLoader) ->
        @scope.sectionName = "Team"

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            #TODO: i18n
            @appTitle.set("Team - " + @scope.project.name)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

        # Finally
        promise.finally tgLoader.pageLoaded

    setRole: (role) ->
        if role
            @scope.filtersRole = role
        else
            @scope.filtersRole = ""

    loadMembers: ->
        return @rs.memberships.list(@scope.projectId, {}, false).then (data) =>
            currentUser = @auth.getUser()
            if not currentUser.photo?
                currentUser.photo = "/images/unnamed.png"

            @scope.currentUser = _.find data, (membership) =>
                return membership.user == currentUser.id

            @scope.totals = {}
            _.forEach data, (membership) =>
                @scope.totals[membership.user] = 0

            @scope.memberships = _.filter data, (membership) =>
                if membership.user && membership.user != currentUser.id && membership.is_user_active
                    return membership

            for membership in @scope.memberships
                if not membership.photo?
                    membership.photo = "/images/unnamed.png"

            return data

    loadProject: ->
        return @rs.projects.getBySlug(@params.pslug).then (project) =>
            @scope.projectId = project.id
            @scope.project = project
            @scope.$emit('project:loaded', project)

            @scope.issuesEnabled = project.is_issues_activated
            @scope.tasksEnabled = project.is_kanban_activated or project.is_backlog_activated
            @scope.wikiEnabled = project.is_wiki_activated

            return project

    loadMemberStats: ->
        return @rs.projects.memberStats(@scope.projectId).then (stats) =>
          totals = {}
          _.forEach @scope.totals, (total, userId) =>
              vals = _.map(stats, (memberStats, statsKey) -> memberStats[userId])
              total = _.reduce(vals, (sum, el) -> sum + el)
              @scope.totals[userId] = total

          @scope.stats = @.processStats(stats)
          @scope.stats.totals = @scope.totals

    processStat: (stat) ->
        max = _.max(stat)
        min = _.min(stat)
        singleStat = _.map stat, (value, key) ->
            if value == min
                return [key, 0.1]
            if value == max
                return [key, 1]
            return [key, (value * 0.5) / max]
        singleStat = _.object(singleStat)
        return singleStat

    processStats: (stats) ->
        for key,value of stats
            stats[key] = @.processStat(value)
        return stats

    loadInitialData: ->
        promise = @.loadProject()
        return promise.then (project) =>
            @.fillUsersAndRoles(project.users, project.roles)
            return @.loadMembers().then(=> @.loadMemberStats())

module.controller("TeamController", TeamController)

#############################################################################
## Team Filters Directive
#############################################################################

TeamFiltersDirective = () ->
    return {
        templateUrl: "team/team-filter.html"
    }

module.directive("tgTeamFilters", [TeamFiltersDirective])

#############################################################################
## Team Member Stats Directive
#############################################################################

TeamMemberStatsDirective = () ->
    return {
        templateUrl: "team/team-member-stats.html",
        scope: {
            stats: "=",
            userId: "=user"
            issuesEnabled: "=issuesenabled"
            tasksEnabled: "=tasksenabled"
            wikiEnabled: "=wikienabled"
        }
    }

module.directive("tgTeamMemberStats", TeamMemberStatsDirective)

#############################################################################
## Team Current User Directive
#############################################################################

TeamMemberCurrentUserDirective = () ->
    return {
        templateUrl: "team/team-member-current-user.html"
        scope: {
            projectId: "=projectid",
            currentUser: "=currentuser",
            stats: "="
            issuesEnabled: "=issuesenabled"
            tasksEnabled: "=tasksenabled"
            wikiEnabled: "=wikienabled"
        }
    }

module.directive("tgTeamCurrentUser", TeamMemberCurrentUserDirective)

#############################################################################
## Team Members Directive
#############################################################################

TeamMembersDirective = () ->
    template = "team/team-members.html"

    return {
        templateUrl: template
        scope: {
            memberships: "=",
            filtersQ: "=filtersq",
            filtersRole: "=filtersrole",
            stats: "="
            issuesEnabled: "=issuesenabled"
            tasksEnabled: "=tasksenabled"
            wikiEnabled: "=wikienabled"
        }
    }

module.directive("tgTeamMembers", TeamMembersDirective)

#############################################################################
## Leave project Directive
#############################################################################

LeaveProjectDirective = ($repo, $confirm, $location, $rs, $navurls) ->
    link = ($scope, $el, $attrs) ->
        $scope.leave = () ->
            #TODO: i18n
            $confirm.ask("Leave this project", "Are you sure you want to leave the project?").then (finish) =>
                promise = $rs.projects.leave($attrs.projectid)

                promise.then =>
                    finish()
                    $confirm.notify("success")
                    $location.path($navurls.resolve("home"))

                promise.then null, (response) ->
                    finish()
                    $confirm.notify('error', response.data._error_message)

    return {
        scope: {},
        templateUrl: "team/leave-project.html",
        link: link
    }

module.directive("tgLeaveProject", ["$tgRepo", "$tgConfirm", "$tgLocation", "$tgResources", "$tgNavUrls", LeaveProjectDirective])
