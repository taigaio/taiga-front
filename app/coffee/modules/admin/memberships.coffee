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
# File: modules/admin/memberships.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
bindMethods = @.taiga.bindMethods

module = angular.module("taigaAdmin")


#############################################################################
## Project Memberships Controller
#############################################################################

class MembershipsController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
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
        "$tgAnalytics",
        "$appTitle"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q,
                  @location, @navUrls, @analytics, @appTitle) ->
        bindMethods(@)

        @scope.sectionName = "Manage Members" #i18n
        @scope.project = {}
        @scope.filters = {}

        promise = @.loadInitialData()

        promise.then  =>
            @appTitle.set("Membership - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "membersform:new:success", =>
            @.loadMembers()
            @analytics.trackEvent("membership", "create", "create memberships on admin", 1)

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            return project

    loadMembers: ->
        httpFilters = @.getUrlFilters()
        return @rs.memberships.list(@scope.projectId, httpFilters).then (data) =>
            @scope.memberships = data.models
            @scope.page = data.current
            @scope.count = data.count
            @scope.paginatedBy = data.paginatedBy
            return data

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadMembers())

    getUrlFilters: ->
        filters = _.pick(@location.search(), "page")
        filters.page = 1 if not filters.page
        return filters

    addNewMembers:  ->
        @rootscope.$broadcast("membersform:new")


module.controller("MembershipsController", MembershipsController)


#############################################################################
## Member Avatar Directive
#############################################################################

paginatorTemplate = """
<ul class="paginator">
    <% if (showPrevious) { %>
    <li class="previous">
        <a href="" class="previous next_prev_button" class="disabled">
            <span i18next="pagination.prev">Prev</span>
        </a>
    </li>
    <% } %>

    <% _.each(pages, function(item) { %>
    <li class="<%- item.classes %>">
        <% if (item.type === "page") { %>
        <a href="" data-pagenum="<%- item.num %>"><%- item.num %></a>
        <% } else if (item.type === "page-active") { %>
        <span class="active"><%- item.num %></span>
        <% } else { %>
        <span>...</span>
        <% } %>
    </li>
    <% }); %>

    <% if (showNext) { %>
    <li class="next">
        <a href="" class="next next_prev_button" class="disabled">
            <span i18next="pagination.next">Next</span>
        </a>
    </li>
    <% } %>
</ul>
"""

MembershipsDirective = ->
    template = _.template(paginatorTemplate)

    linkPagination = ($scope, $el, $attrs, $ctrl) ->
        # Constants
        afterCurrent = 2
        beforeCurrent = 4
        atBegin = 2
        atEnd = 2

        $pagEl = $el.find(".memberships-paginator")

        getNumPages = ->
            numPages = $scope.count / $scope.paginatedBy
            if parseInt(numPages, 10) < numPages
                numPages = parseInt(numPages, 10) + 1
            else
                numPages = parseInt(numPages, 10)

            return numPages

        renderPagination = ->
            numPages = getNumPages()

            if numPages <= 1
                $pagEl.hide()
                return

            pages = []
            options = {}
            options.pages = pages
            options.showPrevious = ($scope.page > 1)
            options.showNext = not ($scope.page == numPages)

            cpage = $scope.page

            for i in [1..numPages]
                if i == (cpage + afterCurrent) and numPages > (cpage + afterCurrent + atEnd)
                    pages.push({classes: "dots", type: "dots"})
                else if i == (cpage - beforeCurrent) and cpage > (atBegin + beforeCurrent)
                    pages.push({classes: "dots", type: "dots"})
                else if i > (cpage + afterCurrent) and i <= (numPages - atEnd)
                else if i < (cpage - beforeCurrent) and i > atBegin
                else if i == cpage
                    pages.push({classes: "active", num: i, type: "page-active"})
                else
                    pages.push({classes: "page", num: i, type: "page"})

            $pagEl.html(template(options))

        $scope.$watch "memberships", (value) ->
            # Do nothing if value is not logical true
            return if not value

            renderPagination()

        $el.on "click", ".memberships-paginator a.next", (event) ->
            event.preventDefault()

            $scope.$apply ->
                $ctrl.selectFilter("page", $scope.page + 1)
                $ctrl.loadMembers()

        $el.on "click", ".memberships-paginator a.previous", (event) ->
            event.preventDefault()
            $scope.$apply ->
                $ctrl.selectFilter("page", $scope.page - 1)
                $ctrl.loadMembers()

        $el.on "click", ".memberships-paginator li.page > a", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            pagenum = target.data("pagenum")

            $scope.$apply ->
                $ctrl.selectFilter("page", pagenum)
                $ctrl.loadMembers()

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        linkPagination($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgMemberships", MembershipsDirective)


#############################################################################
## Member Avatar Directive
#############################################################################

MembershipsRowAvatarDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <img src="<%- imgurl %>" alt="<%- full_name %>">
        <figcaption>
            <span class="name"><%- full_name %></span>
            <span class="email"><%- email %></span>
        </figcaption>
    </figure>
    """)

    link = ($scope, $el, $attrs) ->
        render = (member) ->
            ctx = {
                full_name: if member.full_name then member.full_name else ""
                email: if member.user_email then member.user_email else member.email
                imgurl: if member.photo then member.photo else "/images/unnamed.png"
            }

            html = template(ctx)
            $el.html(html)

        if not $attrs.tgMembershipsRowAvatar?
            return $log.error "MembershipsRowAvatarDirective: the directive need a member"

        member = $scope.$eval($attrs.tgMembershipsRowAvatar)
        render(member)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgMembershipsRowAvatar", ["$log", MembershipsRowAvatarDirective])


#############################################################################
## Member IsAdminCheckbox Directive
#############################################################################

MembershipsRowAdminCheckboxDirective = ($log, $repo, $confirm) ->
    template = _.template("""
    <div class="check">
        <input type="checkbox" id="<%- inputId %>" />
        <div></div>
        <span class="check-text check-yes">Yes</span>
        <span class="check-text check-no">No</span>
    </div>
    """) # TODO: i18n

    link = ($scope, $el, $attrs) ->
        render = (member) ->
            ctx = {inputId: "is-admin-#{member.id}"}

            html = template(ctx)
            $el.html(html)

        if not $attrs.tgMembershipsRowAdminCheckbox?
            return $log.error "MembershipsRowAdminCheckboxDirective: the directive need a member"

        member = $scope.$eval($attrs.tgMembershipsRowAdminCheckbox)
        html = render(member)

        if member.is_owner
            $el.find(":checkbox").prop("checked", true)

        $el.on "click", ":checkbox", (event) =>
            onSuccess = ->
                $confirm.notify("success")

            onError = ->
                $confirm.notify("error")

            target = angular.element(event.currentTarget)
            member.is_owner = target.prop("checked")
            $repo.save(member).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgMembershipsRowAdminCheckbox", ["$log", "$tgRepo", "$tgConfirm",
                                                   MembershipsRowAdminCheckboxDirective])


#############################################################################
## Member RoleSelector Directive
#############################################################################

MembershipsRowRoleSelectorDirective = ($log, $repo, $confirm) ->
    template = _.template("""
    <select>
        <% _.each(roleList, function(role) { %>
        <option value="<%- role.id %>" <% if(selectedRole === role.id){ %>selected="selected"<% } %>>
            <%- role.name %>
        </option>
        <% }); %>
    </select>
    """)

    link = ($scope, $el, $attrs) ->
        render = (member) ->
            ctx = {
                roleList: $scope.roles,
                selectedRole: member.role
            }

            html = template(ctx)
            $el.html(html)

        if not $attrs.tgMembershipsRowRoleSelector?
            return $log.error "MembershipsRowRoleSelectorDirective: the directive need a member"

        $ctrl = $el.controller()
        member = $scope.$eval($attrs.tgMembershipsRowRoleSelector)
        html = render(member)

        $el.on "click", "select", (event) =>
            onSuccess = ->
                $confirm.notify("success")

            onError = ->
                $confirm.notify("error")

            target = angular.element(event.currentTarget)
            newRole = parseInt(target.val(), 10)

            if member.role != newRole
                member.role = newRole
                $repo.save(member).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgMembershipsRowRoleSelector", ["$log", "$tgRepo", "$tgConfirm",
                                                  MembershipsRowRoleSelectorDirective])


#############################################################################
## Member Actions Directive
#############################################################################

MembershipsRowActionsDirective = ($log, $repo, $rs, $confirm) ->
    activedTemplate = _.template("""
    <div class="active">
        Active
    </div>
    <a class="delete" href="">
        <span class="icon icon-delete"></span>
    </a>
    """) # TODO: i18n

    pendingTemplate = _.template("""
    <a class="pending" href="">
        Pending
        <span class="icon icon-reload"></span>
    </a>
    <a class="delete" href="" title="Delete">
        <span class="icon icon-delete"></span>
    </a>
    """) # TODO: i18n

    link = ($scope, $el, $attrs) ->
        render = (member) ->
            if member.user
                html = activedTemplate()
            else
                html = pendingTemplate()

            $el.html(html)

        if not $attrs.tgMembershipsRowActions?
            return $log.error "MembershipsRowActionsDirective: the directive need a member"

        $ctrl = $el.controller()
        member = $scope.$eval($attrs.tgMembershipsRowActions)
        render(member)

        $el.on "click", ".pending", (event) ->
            event.preventDefault()
            onSuccess = ->
                # TODO: i18n
                $confirm.notify("success", "We've sent the invitationi again to '#{$scope.member.email}'.")
            onError = ->
                $confirm.notify("error", "We haven't sent the invitation.") # TODO: i18n

            $rs.memberships.resendInvitation($scope.member.id).then(onSuccess, onError)

        $el.on "click", ".delete", (event) ->
            event.preventDefault()

            title = "Delete member" # TODO: i18n
            message = if member.user then member.full_name else "the invitation to #{member.email}" # TODO: i18n

            $confirm.askOnDelete(title, message).then (finish) ->
                onSuccess = ->
                    finish()
                    $ctrl.loadMembers()
                    $confirm.notify("success", null, "We've deleted #{message}.") # TODO: i18n

                onError = ->
                    finish(false)
                    # TODO: i18in
                    $confirm.notify("error", null, "We have not been able to delete #{message}.")

                $repo.remove(member).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgMembershipsRowActions", ["$log", "$tgRepo", "$tgResources", "$tgConfirm",
                                             MembershipsRowActionsDirective])
