###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
        "tgAppMetaService",
        "$translate",
        "$tgAuth",
        "tgLightboxFactory",
        "tgErrorHandlingService",
        "tgProjectService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @navUrls, @analytics,
                  @appMetaService, @translate, @auth, @lightboxFactory, @errorHandlingService, @projectService) ->
        bindMethods(@)

        @scope.project = {}
        @scope.filters = {}

        promise = @.loadInitialData()

        promise.then  =>
           title = @translate.instant("ADMIN.MEMBERSHIPS.PAGE_TITLE", {projectName:  @scope.project.name})
           description = @scope.project.description
           @appMetaService.setAll(title, description)

        promise.then null, @.onInitialDataError.bind(@)

        @scope.$on "membersform:new:success", =>
            @.loadInitialData()
            @analytics.trackEvent("membership", "create", "create memberships on admin", 1)

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.i_am_admin
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project

        @scope.canAddUsers = project.max_memberships == null || project.max_memberships > project.total_memberships

        @scope.$emit('project:loaded', project)
        return project

    loadMembers: ->
        httpFilters = @.getUrlFilters()

        return @rs.memberships.list(@scope.projectId, httpFilters).then (data) =>
            @scope.memberships = _.filter(data.models, (membership) ->
                                    membership.user == null or membership.is_user_active)

            _.map(@scope.memberships, (member) =>
                if member.is_owner
                    @scope.projectOwnerEmail = member.user_email
            )

            @scope.page = data.current
            @scope.count = data.count
            @scope.paginatedBy = data.paginatedBy
            return data

    loadInitialData: ->
        @.loadProject()

        return @q.all([
            @.loadMembers(),
            @auth.refresh()
        ])

    getUrlFilters: ->
        filters = _.pick(@location.search(), "page")
        filters.page = 1 if not filters.page
        return filters

    # Actions

    addNewMembers:  ->
        @lightboxFactory.create(
            'tg-lb-add-members',
            {
                "class": "lightbox lightbox-add-member",
                "project": "project"
            },
            {
                "project": @scope.project
            }
        )

    showLimitUsersWarningMessage: ->
        title = @translate.instant("ADMIN.MEMBERSHIPS.LIMIT_USERS_WARNING")
        message = @translate.instant("ADMIN.MEMBERSHIPS.LIMIT_USERS_WARNING_MESSAGE", {
            members: @scope.project.max_memberships
        })
        icon = "/" + window._version + "/svg/icons/team-question.svg"
        @confirm.success(title, message, {
            name: icon,
            type: "img"
        })

module.controller("MembershipsController", MembershipsController)


#############################################################################
## Member Avatar Directive
#############################################################################

MembershipsDirective = ($template, $compile) ->
    template = $template.get("admin/admin-membership-paginator.html", true)

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

            html = template(options)
            html = $compile(html)($scope)

            $pagEl.html(html)
            $pagEl.show()

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

module.directive("tgMemberships", ["$tgTemplate", "$compile", MembershipsDirective])


#############################################################################
## Member Avatar Directive
#############################################################################

MembershipsRowAvatarDirective = ($log, $template, $translate, $compile, avatarService) ->
    template = $template.get("admin/memberships-row-avatar.html", true)

    link = ($scope, $el, $attrs) ->
        pending = $translate.instant("ADMIN.MEMBERSHIP.STATUS_PENDING")
        render = (member) ->
            avatar = avatarService.getAvatar(member)

            ctx = {
                full_name: if member.full_name then member.full_name else ""
                email: if member.user_email then member.user_email else member.email
                imgurl: avatar.url
                bg: avatar.bg
                pending: if !member.is_user_active then pending else ""
                isOwner: member.is_owner
            }

            html = template(ctx)
            html = $compile(html)($scope)

            $el.html(html)

        if not $attrs.tgMembershipsRowAvatar?
            return $log.error "MembershipsRowAvatarDirective: the directive need a member"

        member = $scope.$eval($attrs.tgMembershipsRowAvatar)
        render(member)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module.directive("tgMembershipsRowAvatar", ["$log", "$tgTemplate", '$translate', "$compile", "tgAvatarService", MembershipsRowAvatarDirective])


#############################################################################
## Member IsAdminCheckbox Directive
#############################################################################

MembershipsRowAdminCheckboxDirective = ($log, $repo, $confirm, $template, $compile) ->
    template = $template.get("admin/admin-memberships-row-checkbox.html", true)

    link = ($scope, $el, $attrs) ->
        $scope.$on "$destroy", ->
            $el.off()

        if not $attrs.tgMembershipsRowAdminCheckbox?
            return $log.error "MembershipsRowAdminCheckboxDirective: the directive need a member"

        member = $scope.$eval($attrs.tgMembershipsRowAdminCheckbox)

        if member.is_owner
            $el.find(".js-check").remove()
            return

        render = (member) ->
            ctx = {inputId: "is-admin-#{member.id}"}

            html = template(ctx)
            html = $compile(html)($scope)

            $el.html(html)

        $el.on "click", ":checkbox", (event) =>
            onSuccess = ->
                $confirm.notify("success")

            onError = (data) ->
                member.revert()
                $el.find(":checkbox").prop("checked", member.is_admin)
                $confirm.notify("error", data.is_admin[0])

            target = angular.element(event.currentTarget)
            member.is_admin = target.prop("checked")
            $repo.save(member).then(onSuccess, onError)

        html = render(member)

        if member.is_admin
            $el.find(":checkbox").prop("checked", true)

    return {link: link}


module.directive("tgMembershipsRowAdminCheckbox", ["$log", "$tgRepo", "$tgConfirm",
    "$tgTemplate", "$compile", MembershipsRowAdminCheckboxDirective])


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
                roleList: $scope.project.roles,
                selectedRole: member.role
            }

            html = template(ctx)
            $el.html(html)

        if not $attrs.tgMembershipsRowRoleSelector?
            return $log.error "MembershipsRowRoleSelectorDirective: the directive need a member"

        $ctrl = $el.controller()
        member = $scope.$eval($attrs.tgMembershipsRowRoleSelector)
        html = render(member)

        $el.on "change", "select", (event) =>
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

MembershipsRowActionsDirective = ($log, $repo, $rs, $confirm, $compile, $translate, $location,
                                  $navUrls, lightboxFactory, projectService) ->
    activedTemplate = """
    <div class="active"
         translate="ADMIN.MEMBERSHIP.STATUS_ACTIVE">
    </div>
    <a class="delete" href=""
       title="{{ 'ADMIN.MEMBERSHIP.DELETE_MEMBER' | translate }}">
        <tg-svg svg-icon="icon-trash"></tg-svg>
    </a>
    """

    pendingTemplate = """
    <a class="resend js-resend" href=""
       title="{{ 'ADMIN.MEMBERSHIP.RESEND' | translate }}"
       translate="ADMIN.MEMBERSHIP.RESEND">
    </a>
    <a class="delete" href=""
       title="{{ 'ADMIN.MEMBERSHIP.DELETE_MEMBER' | translate }}">
        <tg-svg svg-icon="icon-trash"></tg-svg>
    </a>
    """

    link = ($scope, $el, $attrs) ->
        render = (member) ->
            if member.user
                html = $compile(activedTemplate)($scope)
            else
                html = $compile(pendingTemplate)($scope)

            $el.html(html)

        if not $attrs.tgMembershipsRowActions?
            return $log.error "MembershipsRowActionsDirective: the directive need a member"

        $ctrl = $el.controller()
        member = $scope.$eval($attrs.tgMembershipsRowActions)
        render(member)

        $el.on "click", ".js-resend", (event) ->
            event.preventDefault()
            onSuccess = ->
                text = $translate.instant("ADMIN.MEMBERSHIP.SUCCESS_SEND_INVITATION", {
                    email: $scope.member.email
                })
                $confirm.notify("success", text)
            onError = ->
                text = $translate.instant("ADMIM.MEMBERSHIP.ERROR_SEND_INVITATION")
                $confirm.notify("error", text)

            $rs.memberships.resendInvitation($scope.member.id).then(onSuccess, onError)

        leaveConfirm = () ->
            title = $translate.instant("ADMIN.MEMBERSHIP.DELETE_MEMBER")
            defaultMsg = $translate.instant("ADMIN.MEMBERSHIP.DEFAULT_DELETE_MESSAGE", {email: member.email})
            message = if member.user then member.full_name else defaultMsg

            $confirm.askOnDelete(title, message).then (askResponse) ->
                onSuccess = =>
                    askResponse.finish()
                    if member.user != $scope.user.id
                        if $scope.page > 1 && ($scope.count - 1) <= $scope.paginatedBy
                            $ctrl.selectFilter("page", $scope.page - 1)

                        projectService.fetchProject().then =>
                            $ctrl.loadInitialData()
                    else
                        $location.path($navUrls.resolve("home"))

                    text = $translate.instant("ADMIN.MEMBERSHIP.SUCCESS_DELETE", {message: message})
                    $confirm.notify("success", text, null, 5000)

                onError = =>
                    askResponse.finish(false)

                    text = $translate.instant("ADMIN.MEMBERSHIP.ERROR_DELETE", {message: message})
                    $confirm.notify("error", text)

                $repo.remove(member).then(onSuccess, onError)

        $el.on "click", ".delete", (event) ->
            event.preventDefault()

            if $scope.project.owner.id == member.user
                isCurrentUser = $scope.user.id == member.user

                lightboxFactory.create("tg-lightbox-leave-project-warning", {
                    class: "lightbox lightbox-leave-project-warning"
                }, {
                    isCurrentUser: isCurrentUser,
                    project: $scope.project
                })
            else
                leaveConfirm()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgMembershipsRowActions", ["$log", "$tgRepo", "$tgResources", "$tgConfirm", "$compile",
                                             "$translate", "$tgLocation", "$tgNavUrls", "tgLightboxFactory",
                                             "tgProjectService", MembershipsRowActionsDirective])


#############################################################################
## No more memberships explanation directive
#############################################################################

NoMoreMembershipsExplanationDirective = () ->
    return {
          templateUrl: "admin/no-more-memberships-explanation.html"
          scope: {
              project: "=",
              ownerEmail: "="
          }
    }

module.directive("tgNoMoreMembershipsExplanation", [NoMoreMembershipsExplanationDirective])
