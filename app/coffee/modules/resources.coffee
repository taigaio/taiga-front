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
# File: modules/resources.coffee
###

taiga = @.taiga

class ResourcesService extends taiga.Service

urls = {
    "auth": "/api/v1/auth"
    "auth-register": "/api/v1/auth/register"
    "invitations": "/api/v1/invitations"
    "permissions": "/api/v1/permissions"
    "roles": "/api/v1/roles"
    "projects": "/api/v1/projects"
    "memberships": "/api/v1/memberships"
    "bulk-create-memberships": "/api/v1/memberships/bulk_create"
    "milestones": "/api/v1/milestones"
    "userstories": "/api/v1/userstories"
    "bulk-create-us": "/api/v1/userstories/bulk_create"
    "bulk-update-us-order": "/api/v1/userstories/bulk_update_order"
    "userstories-restore": "/api/v1/userstories/%s/restore"
    "tasks": "/api/v1/tasks"
    "bulk-create-tasks": "/api/v1/tasks/bulk_create"
    "tasks-restore": "/api/v1/tasks/%s/restore"
    "issues": "/api/v1/issues"
    "bulk-create-issues": "/api/v1/issues/bulk_create"
    "issues-restore": "/api/v1/issues/%s/restore"
    "wiki": "/api/v1/wiki"
    "wiki-restore": "/api/v1/wiki/%s/restore"
    "wiki-links": "/api/v1/wiki-links"
    "choices/userstory-statuses": "/api/v1/userstory-statuses"
    "choices/userstory-statuses/bulk-update-order": "/api/v1/userstory-statuses/bulk_update_order"
    "choices/points": "/api/v1/points"
    "choices/points/bulk-update-order": "/api/v1/points/bulk_update_order"
    "choices/task-statuses": "/api/v1/task-statuses"
    "choices/task-statuses/bulk-update-order": "/api/v1/task-statuses/bulk_update_order"
    "choices/issue-statuses": "/api/v1/issue-statuses"
    "choices/issue-statuses/bulk-update-order": "/api/v1/issue-statuses/bulk_update_order"
    "choices/issue-types": "/api/v1/issue-types"
    "choices/issue-types/bulk-update-order": "/api/v1/issue-types/bulk_update_order"
    "choices/priorities": "/api/v1/priorities"
    "choices/priorities/bulk-update-order": "/api/v1/priorities/bulk_update_order"
    "choices/severities": "/api/v1/severities"
    "choices/severities/bulk-update-order": "/api/v1/severities/bulk_update_order"
    "search": "/api/v1/search"
    "sites": "/api/v1/sites"
    "project-templates": "/api/v1/project-templates"
    "site-members": "/api/v1/site-members"
    "site-projects": "/api/v1/site-projects"
    "users": "/api/v1/users"
    "users-password-recovery": "/api/v1/users/password_recovery"
    "users-change-password-from-recovery": "/api/v1/users/change_password_from_recovery"
    "users-change-password": "/api/v1/users/change_password"
    "resolver": "/api/v1/resolver"
    "userstory-statuses": "/api/v1/userstory-statuses"
    "points": "/api/v1/points"
    "task-statuses": "/api/v1/task-statuses"
    "issue-statuses": "/api/v1/issue-statuses"
    "issue-types": "/api/v1/issue-types"
    "priorities": "/api/v1/priorities"
    "severities": "/api/v1/severities"

    # History
    "history/userstory": "/api/v1/history/userstory"
    "history/issue": "/api/v1/history/issue"
    "history/task": "/api/v1/history/task"
    "history/wiki": "/api/v1/history/wiki"

    # Attachments
    "userstories/attachments": "/api/v1/userstories/attachments"
    "issues/attachments": "/api/v1/issues/attachments"
    "tasks/attachments": "/api/v1/tasks/attachments"
    "wiki/attachments": "/api/v1/wiki/attachments"
}

# Initialize api urls service
initUrls = ($log, $urls) ->
    $log.debug "Initialize api urls"
    $urls.update(urls)

# Initialize resources service populating it with methods
# defined in separated files.
initResources = ($log, $rs) ->
    $log.debug "Initialize resources"
    providers = _.toArray(arguments).slice(2)

    for provider in providers
        provider($rs)

module = angular.module("taigaResources", ["taigaBase"])
module.service("$tgResources", ResourcesService)

# Module entry point
module.run(["$log", "$tgUrls", initUrls])
module.run([
    "$log",
    "$tgResources",
    "$tgProjectsResourcesProvider",
    "$tgMembershipsResourcesProvider",
    "$tgInvitationsResourcesProvider",
    "$tgRolesResourcesProvider",
    "$tgSprintsResourcesProvider",
    "$tgUserstoriesResourcesProvider",
    "$tgTasksResourcesProvider",
    "$tgIssuesResourcesProvider",
    "$tgWikiResourcesProvider",
    "$tgSearchResourcesProvider",
    "$tgAttachmentsResourcesProvider",
    "$tgMdRenderResourcesProvider",
    initResources
])
