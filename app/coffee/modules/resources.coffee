###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
    # Auth
    "auth": "/auth"
    "auth-register": "/auth/register"
    "invitations": "/invitations"

    # User
    "users": "/users"
    "by_username": "/users/by_username"
    "users-password-recovery": "/users/password_recovery"
    "users-change-password-from-recovery": "/users/change_password_from_recovery"
    "users-change-password": "/users/change_password"
    "users-change-email": "/users/change_email"
    "users-cancel-account": "/users/cancel"
    "user-stats": "/users/%s/stats"
    "user-liked": "/users/%s/liked"
    "user-voted": "/users/%s/voted"
    "user-watched": "/users/%s/watched"
    "user-contacts": "/users/%s/contacts"

    # User - Notification
    "permissions": "/permissions"
    "notify-policies": "/notify-policies"

    # User - Storage
    "user-storage": "/user-storage"

    # Memberships
    "memberships": "/memberships"
    "bulk-create-memberships": "/memberships/bulk_create"

    # Roles & Permissions
    "roles": "/roles"
    "permissions": "/permissions"

    # Resolver
    "resolver": "/resolver"

    # Project
    "projects": "/projects"
    "project-templates": "/project-templates"
    "project-modules": "/projects/%s/modules"
    "bulk-update-projects-order": "/projects/bulk_update_order"
    "project-like": "/projects/%s/like"
    "project-unlike": "/projects/%s/unlike"
    "project-watch": "/projects/%s/watch"
    "project-unwatch": "/projects/%s/unwatch"

    # Project Values - Choises
    "userstory-statuses": "/userstory-statuses"
    "points": "/points"
    "task-statuses": "/task-statuses"
    "issue-statuses": "/issue-statuses"
    "issue-types": "/issue-types"
    "priorities": "/priorities"
    "severities": "/severities"

    # Milestones/Sprints
    "milestones": "/milestones"

    # User stories
    "userstories": "/userstories"
    "bulk-create-us": "/userstories/bulk_create"
    "bulk-update-us-backlog-order": "/userstories/bulk_update_backlog_order"
    "bulk-update-us-sprint-order": "/userstories/bulk_update_sprint_order"
    "bulk-update-us-kanban-order": "/userstories/bulk_update_kanban_order"
    "userstories-filters": "/userstories/filters_data"
    "userstory-upvote": "/userstories/%s/upvote"
    "userstory-downvote": "/userstories/%s/downvote"
    "userstory-watch": "/userstories/%s/watch"
    "userstory-unwatch": "/userstories/%s/unwatch"

    # Tasks
    "tasks": "/tasks"
    "bulk-create-tasks": "/tasks/bulk_create"
    "bulk-update-task-taskboard-order": "/tasks/bulk_update_taskboard_order"
    "task-upvote": "/tasks/%s/upvote"
    "task-downvote": "/tasks/%s/downvote"
    "task-watch": "/tasks/%s/watch"
    "task-unwatch": "/tasks/%s/unwatch"

    # Issues
    "issues": "/issues"
    "bulk-create-issues": "/issues/bulk_create"
    "issues-filters": "/issues/filters_data"
    "issue-upvote": "/issues/%s/upvote"
    "issue-downvote": "/issues/%s/downvote"
    "issue-watch": "/issues/%s/watch"
    "issue-unwatch": "/issues/%s/unwatch"

    # Wiki pages
    "wiki": "/wiki"
    "wiki-restore": "/wiki/%s/restore"
    "wiki-links": "/wiki-links"

    # History
    "history/us": "/history/userstory"
    "history/issue": "/history/issue"
    "history/task": "/history/task"
    "history/wiki": "/history/wiki"

    # Attachments
    "attachments/us": "/userstories/attachments"
    "attachments/issue": "/issues/attachments"
    "attachments/task": "/tasks/attachments"
    "attachments/wiki_page": "/wiki/attachments"

    # Custom Attributess
    "custom-attributes/userstory": "/userstory-custom-attributes"
    "custom-attributes/issue": "/issue-custom-attributes"
    "custom-attributes/task": "/task-custom-attributes"

    # Custom Attributess - Values
    "custom-attributes-values/userstory": "/userstories/custom-attributes-values"
    "custom-attributes-values/issue": "/issues/custom-attributes-values"
    "custom-attributes-values/task": "/tasks/custom-attributes-values"

    # Webhooks
    "webhooks": "/webhooks"
    "webhooks-test": "/webhooks/%s/test"
    "webhooklogs": "/webhooklogs"
    "webhooklogs-resend": "/webhooklogs/%s/resend"

    # Reports - CSV
    "userstories-csv": "/userstories/csv?uuid=%s"
    "tasks-csv": "/tasks/csv?uuid=%s"
    "issues-csv": "/issues/csv?uuid=%s"

    # Timeline
    "timeline-profile": "/timeline/profile"
    "timeline-user": "/timeline/user"
    "timeline-project": "/timeline/project"

    # Search
    "search": "/search"

    # Export/Import
    "exporter": "/exporter"
    "importer": "/importer/load_dump"

    # Feedback
    "feedback": "/feedback"

    # locales
    "locales": "/locales"

    # Application tokens
    "applications": "/applications"
    "application-tokens": "/application-tokens"

    # Stats
    "stats-discover": "/stats/discover"
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
    "$tgCustomAttributesResourcesProvider",
    "$tgCustomAttributesValuesResourcesProvider",
    "$tgMembershipsResourcesProvider",
    "$tgNotifyPoliciesResourcesProvider",
    "$tgInvitationsResourcesProvider",
    "$tgRolesResourcesProvider",
    "$tgUserSettingsResourcesProvider",
    "$tgSprintsResourcesProvider",
    "$tgUserstoriesResourcesProvider",
    "$tgTasksResourcesProvider",
    "$tgIssuesResourcesProvider",
    "$tgWikiResourcesProvider",
    "$tgSearchResourcesProvider",
    "$tgMdRenderResourcesProvider",
    "$tgHistoryResourcesProvider",
    "$tgKanbanResourcesProvider",
    "$tgModulesResourcesProvider",
    "$tgWebhooksResourcesProvider",
    "$tgWebhookLogsResourcesProvider",
    "$tgLocalesResourcesProvider",
    "$tgUsersResourcesProvider",
    initResources
])
