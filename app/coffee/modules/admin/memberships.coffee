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

module = angular.module("taigaAdmin")


#############################################################################
## Project Memberships Controller
#############################################################################

class MembershipsController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        _.bindAll(@)

        @scope.sectionName = "Memberships"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            return project

    loadMembers: ->
        return @rs.memberships.list(@scope.projectId).then (data) =>
            @scope.memberships = data.models
            return data

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadMembers())


module.controller("MembershipsController", MembershipsController)


#############################################################################
## Member Avatar Directive
#############################################################################

MembershipsMemberAvatarDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <img src="<%= imgurl %>" alt="<%- full_name %>">
        <figcaption>
            <span class="name"><%- full_name %></span>
            <span class="email"><%- email %></span>
        </figcaption>
    </figure>
    """)

    render = (member) ->
        ctx = {
            full_name: if member.full_name then member.full_name else "------"
            email: member.email
            imgurl: if member.photo then member.photo else "http://thecodeplayer.com/u/uifaces/12.jpg"
        }

        return template(ctx)

    link = ($scope, $el, $attrs) ->
        if not $attrs.tgMembershipsMemberAvatar?
            return $log.error "MembershipsMemberAvatarDirective: the directive need a member"

        member = $scope.$eval($attrs.tgMembershipsMemberAvatar)
        html = render(member)
        $el.html(html)

    return {
        link: link
    }


module.directive("tgMembershipsMemberAvatar", ["$log", MembershipsMemberAvatarDirective])


#############################################################################
## Member Actions Directive
#############################################################################

MembershipsMemberActionsDirective = ($log) ->
    activedTemplate = _.template("""
    <div class="active">
        Active
    </div>
    <a class="delete" href="">
        <span class="icon icon-delete"></span>
    </a>
    """)
    pendingTemplate = _.template("""
    <a class="pending" href="">
        Pending
        <span class="icon icon-reload"></span>
    </a>
    <a class="delete" href="">
        <span class="icon icon-delete"></span>
    </a>
    """)

    render = (member) ->
        if member.user
            return activedTemplate()
        return pendingTemplate()

    link = ($scope, $el, $attrs) ->
        if not $attrs.tgMembershipsMemberActions?
            return $log.error "MembershipsMemberActionsDirective: the directive need a member"

        member = $scope.$eval($attrs.tgMembershipsMemberActions)
        html = render(member)
        $el.html(html)

    return {
        link: link
    }


module.directive("tgMembershipsMemberActions", ["$log", MembershipsMemberActionsDirective])
