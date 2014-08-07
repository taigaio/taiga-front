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
bindOnce = @.taiga.bindOnce

module = angular.module("taigaAdmin")


#############################################################################
## Project Roles Controller
#############################################################################

class RolesController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        _.bindAll(@)

        @scope.sectionName = "Roles" #i18n
        @scope.project = {}

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            return project

    loadRoles: ->
        return @rs.roles.list(@scope.projectId).then (data) =>
            @scope.roles = data
            @scope.role = @scope.roles[0]
            return data

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadRoles())

    setRole: (role) ->
        @scope.role = role
        @scope.$broadcast("role:changed", @scope.role)

    delete: ->
        # TODO: i18n
        title = "Delete Role"
        subtitle = @scope.role.name

        @confirm.ask(title, subtitle).then =>
            promise = @repo.remove(@scope.role)
            promise.then =>
                @confirm.notify('success')
                @.loadRoles()
            promise.then null, =>
                @confirm.notify('error')

    setComputable: ->
        onSuccess = null

        onError = =>
            @confirm.notify("error")
            @scope.role.revert()

        @repo.save(@scope.role).then onSuccess, onError


module.controller("RolesController", RolesController)


RolesDirective =  ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgRoles", RolesDirective)

NewRoleDirective = ($tgrepo, $confirm) ->
    DEFAULT_PERMISSIONS = ["view_project", "view_milestones", "view_us", "view_tasks", "view_issues"]

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", "a.add-button", (event) ->
            event.preventDefault()
            $el.find(".new").removeClass("hidden")
            $el.find(".new").focus()
            $el.find(".add-button").hide()

        $el.on "keyup", ".new", (event) ->
            event.preventDefault()
            if event.keyCode == 13  # Enter key
                target = angular.element(event.currentTarget)
                newRole = {
                    project: $scope.projectId
                    name: target.val()
                    permissions: DEFAULT_PERMISSIONS
                    order: _.max($scope.roles, (r) -> r.order).order + 1
                    computable: false
                }

                $el.find(".new").addClass("hidden")
                $el.find(".new").val('')

                onSuccess = (role) ->
                    $scope.roles.push(role)
                    $ctrl.setRole(role)
                    $el.find(".add-button").show()

                onError = ->
                    $confirm.notify("error")

                $tgrepo.create("roles", newRole).then(onSuccess, onError)

            else if event.keyCode == 27  # ESC key
                target = angular.element(event.currentTarget)
                $el.find(".new").addClass("hidden")
                $el.find(".new").val('')
                $el.find(".add-button").show()

    return {link:link}

module.directive("tgNewRole", ["$tgRepo", "$tgConfirm", NewRoleDirective])


# Use category-config.scss styles
RolePermissionsDirective = ($repo, $confirm) ->
    resumeTemplate = _.template("""
    <div class="resume-title"><%- category.name %></div>
    <div class="count"><%- category.activePermissions %>/<%- category.permissions.length %></div>
    <div class="summary-role">
    <% _.each(category.permissions, function(permission) { %>
        <div class="role-summary-single <% if(permission.active) { %>active<% } %>"
             title="<%- permission.description %>"></div>
    <% }) %>
    </div>
    <div class="icon icon-arrow-bottom"></div>
    """)

    categoryTemplate = _.template("""
    <div class="category-config" data-id="<%- index %>">
        <div class="resume">
        </div>
        <div class="category-items">
            <div class="items-container">
            <% _.each(category.permissions, function(permission) { %>
                <div class="category-item" data-id="<%- permission.key %>"> <%- permission.description %>
                    <div class="check">
                        <input type="checkbox" <% if(permission.active) { %>checked="checked"<% } %>/>
                        <div></div>
                    </div>
                </div>
            <% }) %>
            </div>
        </div>
    </div>
    """)

    baseTemplate = _.template("""
    <div class="category-config-list"></div>
    """)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        generateCategoriesFromRole = (role) ->
            setActivePermissions = (permissions) ->
                return _.map(permissions, (x) -> _.extend({}, x, {active: x["key"] in role.permissions}))

            setActivePermissionsPerCategory = (category) ->
                return _.map(category, (x) ->
                    _.extend({}, x, {
                        activePermissions: _.filter(x["permissions"], "active").length
                    })
                )

            categories = []

            milestonePermissions = [
                { key: "view_milestones", description: "View milestones" }
                { key: "add_milestone", description: "Add milestone" }
                { key: "modify_milestone", description: "Modify milestone" }
                { key: "delete_milestone", description: "Delete milestone" }
            ]
            categories.push({ name: "Milestones", permissions: setActivePermissions(milestonePermissions) })

            userStoryPermissions = [
                { key: "view_us", description: "View user story" }
                { key: "add_us", description: "Add user story" }
                { key: "modify_us", description: "Modify user story" }
                { key: "delete_us", description: "Delete user story" }
            ]
            categories.push({ name: "User Stories", permissions: setActivePermissions(userStoryPermissions) })

            taskPermissions = [
                { key: "view_tasks", description: "View tasks" }
                { key: "add_task", description: "Add task" }
                { key: "modify_task", description: "Modify task" }
                { key: "delete_task", description: "Delete task" }
            ]
            categories.push({ name: "Tasks", permissions: setActivePermissions(taskPermissions) })

            issuePermissions = [
                { key: "view_issues", description: "View issues" }
                { key: "add_issue", description: "Add issue" }
                { key: "modify_issue", description: "Modify issue" }
                { key: "delete_issue", description: "Delete issue" }
                { key: "vote_issues", description: "Vote issues" }
            ]
            categories.push({ name: "Issues", permissions: setActivePermissions(issuePermissions) })

            wikiPermissions = [
                { key: "view_wiki_pages", description: "View wiki pages" }
                { key: "add_wiki_page", description: "Add wiki page" }
                { key: "modify_wiki_page", description: "Modify wiki page" }
                { key: "delete_wiki_page", description: "Delete wiki page" }
                { key: "view_wiki_links", description: "View wiki links" }
                { key: "add_wiki_link", description: "Add wiki link" }
                { key: "modify_wiki_link", description: "Modify wiki link" }
                { key: "delete_wiki_link", description: "Delete wiki link" }
            ]
            categories.push({ name: "Wiki", permissions: setActivePermissions(wikiPermissions) })

            return setActivePermissionsPerCategory(categories)

        renderResume = (element, category) ->
            element.find(".resume").html(resumeTemplate({category: category}))

        renderCategory = (category, index) ->
            html = categoryTemplate({category: category, index: index})
            html = angular.element(html)
            renderResume(html, category)
            return html

        renderPermissions = () ->
            $el.off()
            html = baseTemplate()
            _.each generateCategoriesFromRole($scope.role), (category, index) ->
                html = angular.element(html).append(renderCategory(category, index))

            $el.html(html)
            $el.on "click", ".resume", (event) ->
                event.preventDefault()
                target = angular.element(event.currentTarget)
                target.next().toggleClass("open")

            $el.on "change", ".category-item input", (event) ->
                getActivePermissions = ->
                    activePermissions = _.filter($el.find(".category-item input"), (t) -> angular.element(t).is(":checked"))
                    activePermissions = _.sortBy(_.map(activePermissions, (t) ->
                        permission = angular.element(t).parents(".category-item").data("id")
                    ))
                    activePermissions.push("view_project")
                    return activePermissions
                target = angular.element(event.currentTarget)
                $scope.role.permissions = getActivePermissions()

                onSuccess = (role) ->
                    categories = generateCategoriesFromRole(role)
                    categoryId = target.parents(".category-config").data("id")
                    renderResume(target.parents(".category-config"), categories[categoryId])

                onError = ->
                    $confirm.notify("error")
                    target.prop "checked", !target.prop("checked")
                    $scope.role.permissions = getActivePermissions()

                $repo.save($scope.role).then onSuccess, onError


        $scope.$on "$destroy", ->
            $el.off()

        $scope.$on "role:changed", ->
            renderPermissions()

        bindOnce($scope, $attrs.ngModel, renderPermissions)

    return {link:link}

module.directive("tgRolePermissions", ['$tgRepo', '$tgConfirm', RolePermissionsDirective])
