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
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$q",
        "$appTitle",
        "$tgAuth"
        "tgLoader"
    ]

    constructor: (@scope, @repo, @rs, @params, @q, @appTitle, @auth, tgLoader) ->
        @scope.sectionName = "Team"

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            #TODO: i18n
            @appTitle.set("Team - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

        @scope.currentUser = @auth.getUser()

    setRole: (role) ->
        if role
            @scope.filtersRole = role
        else
            @scope.filtersRole = ""

    loadMembers: ->
        return @rs.memberships.list(@scope.projectId, {}, false).then (data) =>
            @scope.memberships = _.filter(data, (membership) => membership.user?)
            return data

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)

            return project

    loadMemberStats: ->
        return @rs.projects.memberStats(@scope.projectId).then (stats) =>
            @scope.stats = @.processStats(stats)

    processStat: (stat) ->
        max = _.max(stat)
        min = _.min(stat)
        singleStat = _.map stat, (value, key) ->
            if value == max
                return [key, 1]
            else if value == min
                return [key, 0.1]
            return [key, (value * 0.5) / max]
        singleStat = _.object(singleStat)
        return singleStat

    processStats: (stats) ->
        for key,value of stats
            stats[key] = @.processStat(value)
        return stats

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadMembers())
                      .then(=> @.loadMemberStats())

module.controller("TeamController", TeamController)

#############################################################################
## Team Filters Directive
#############################################################################

TeamFiltersDirective = () ->
    template = """
    <ul>
        <li>
            <a ng-class="{active: !filtersRole.id}" ng-click="ctrl.setRole()" href="">
                <span class="title">All</span>
                <span class="icon icon-arrow-right"></span>
            </a>
        </li>
        <li ng-repeat="role in roles">
            <a ng-class="{active: role.id == filtersRole.id}" ng-click="ctrl.setRole(role)" href="">
                <span class="title" tg-bo-bind="role.name"></span>
                <span class="icon icon-arrow-right"></span>
            </a>
        </li>
    </ul>
    """

    return {
        template: template
    }

module.directive("tgTeamFilters", [TeamFiltersDirective])

#############################################################################
## Team Member Stats Directive
#############################################################################

TeamMemberStatsDirective = () ->
    template = """
        <div class="attribute">
            <span class="icon icon-briefcase" ng-style="{'opacity': stats.closed_bugs[userId]}" ng-class="{'top': stats.closed_bugs[user.user] == 1}"></span>
        </div>
        <div class="attribute">
            <span class="icon icon-iocaine" ng-style="{'opacity': stats.iocaine_tasks[userId]}" ng-class="{'top': stats.iocaine_tasks[user.user] == 1}"></span>
        </div>
        <div class="attribute">
            <span class="icon icon-writer" ng-style="{'opacity': stats.wiki_changes[userId]}" ng-class="{'top': stats.wiki_changes[user.user] == 1}"></span>
        </div>
        <div class="attribute">
            <span class="icon icon-bug" ng-style="{'opacity': stats.created_bugs[userId]}" ng-class="{'top': stats.created_bugs[user.user] == 1}"></span>
        </div>
        <div class="attribute">
            <span class="icon icon-tasks" ng-style="{'opacity': stats.closed_tasks[userId]}" ng-class="{'top': stats.closed_tasks[user.user] == 1}"></span>
        </div>
        <div class="attribute">
            <span class="points"></span>
        </div>
    """
    return {
        template: template,
        scope: {
            "stats": "=",
            "userId": "=user"
        }
    }

module.directive("tgTeamMemberStats", TeamMemberStatsDirective)

#############################################################################
## Team Member Directive
#############################################################################

TeamMemberCurrentUserDirective = () ->
    template = """
        <div class="row">
            <div class="username">
                <figure class="avatar">
                    <img tg-bo-src="currentUser.photo", tg-bo-alt="currentUser.username" />
                    <figcaption>
                        <span class="name" tg-bo-bind="currentUser.username"></span>
                        <div tg-leave-project></div>
                    </figcaption>
                </figure>
            </div>
            <div class="member-stats" tg-team-member-stats stats="stats" user="currentUser.id"></div>
        </div>
    """
    return {
        template: template
        scope: {
            currentUser: "=currentuser",
            stats: "="
        }
    }

module.directive("tgTeamCurrentUser", TeamMemberCurrentUserDirective)

#############################################################################
## Team Members Directive
#############################################################################

TeamMembersDirective = () ->
    template = """
        <div class="row member" ng-repeat="user in memberships | filter:filtersQ | filter:{role: filtersRole.id}">
            <div class="username">
                <figure class="avatar">
                    <img tg-bo-src="user.photo", tg-bo-alt="user.full_name" />
                    <figcaption>
                        <span class="name" tg-bo-bind="user.full_name"></span>
                        <span class="position" tg-bo-bind="user.role_name"></span>
                    </figcaption>
                </figure>
            </div>
            <div class="member-stats" tg-team-member-stats stats="stats" user="user.user"></div>
        </div>
    """
    return {
        template: template
        scope: {
            memberships: "=",
            filtersQ: "=filtersq",
            filtersRole: "=filtersrole",
            stats: "="
        }
    }

module.directive("tgTeamMembers", TeamMembersDirective)

#############################################################################
## Leave project Directive
#############################################################################

LeaveProjectDirective = ($repo, $confirm, $location) ->
    template= """
        <a ng-click="leave()" href="" class="leave-project">
            <span class="icon icon-delete"></span>Leave this project
        </a>
    """ #TODO: i18n

    link = ($scope) ->
        $scope.leave = () ->
            $confirm.ask("Leave this project", "Are you sure you want to leave the project?")#TODO: i18n
                .then (finish) =>
                    console.log "TODO"
    return {
        scope: {},
        template: template,
        link: link
    }

module.directive("tgLeaveProject", ["$tgRepo", "$tgConfirm", "$tgLocation", LeaveProjectDirective])
