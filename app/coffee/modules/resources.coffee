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
    "users-export": "/users/export"
    "user-stats": "/users/%s/stats"
    "user-liked": "/users/%s/liked"
    "user-voted": "/users/%s/voted"
    "user-watched": "/users/%s/watched"
    "user-contacts": "/users/%s/contacts"
    "user-me": "/users/me"

    # User - Notification
    "permissions": "/permissions"
    "notify-policies": "/notify-policies"

    # User Project Settings
    "user-project-settings": "/user-project-settings"

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
    "project-contact": "contact"
    "project-transfer-validate-token": "/projects/%s/transfer_validate_token"
    "project-transfer-accept": "/projects/%s/transfer_accept"
    "project-transfer-reject": "/projects/%s/transfer_reject"
    "project-transfer-request": "/projects/%s/transfer_request"
    "project-transfer-start": "/projects/%s/transfer_start"

    # Project Values - Attributes
    "epic-statuses": "/epic-statuses"
    "userstory-statuses": "/userstory-statuses"
    "userstory-due-dates": "/userstory-due-dates"
    "userstory-due-dates-create-default": "/userstory-due-dates/create_default"
    "points": "/points"
    "task-statuses": "/task-statuses"
    "task-due-dates": "/task-due-dates"
    "task-due-dates-create-default": "/task-due-dates/create_default"
    "issue-statuses": "/issue-statuses"
    "issue-due-dates": "/issue-due-dates"
    "issue-due-dates-create-default": "/issue-due-dates/create_default"
    "issue-types": "/issue-types"
    "priorities": "/priorities"
    "severities": "/severities"

    # Milestones/Sprints
    "milestones": "/milestones"

    # Epics
    "epics": "/epics"
    "epic-upvote": "/epics/%s/upvote"
    "epic-downvote": "/epics/%s/downvote"
    "epic-watch": "/epics/%s/watch"
    "epic-unwatch": "/epics/%s/unwatch"
    "epic-related-userstories": "/epics/%s/related_userstories"
    "epic-related-userstories-bulk-create": "/epics/%s/related_userstories/bulk_create"

    # User stories
    "userstories": "/userstories"
    "bulk-create-us": "/userstories/bulk_create"
    "bulk-update-us-backlog-order": "/userstories/bulk_update_backlog_order"
    "bulk-update-us-milestone": "/userstories/bulk_update_milestone"
    "bulk-update-us-miles-order": "/userstories/bulk_update_sprint_order"
    "bulk-update-us-kanban-order": "/userstories/bulk_update_kanban_order"
    "bulk-update-us-milestone": "/userstories/bulk_update_milestone"
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
    "task-filters": "/tasks/filters_data"

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
    "history/epic": "/history/epic"
    "history/us": "/history/userstory"
    "history/issue": "/history/issue"
    "history/task": "/history/task"
    "history/wiki": "/history/wiki/%s"

    # Attachments
    "attachments/epic": "/epics/attachments"
    "attachments/us": "/userstories/attachments"
    "attachments/issue": "/issues/attachments"
    "attachments/task": "/tasks/attachments"
    "attachments/wiki_page": "/wiki/attachments"

    # Custom Attributess
    "custom-attributes/epic": "/epic-custom-attributes"
    "custom-attributes/userstory": "/userstory-custom-attributes"
    "custom-attributes/task": "/task-custom-attributes"
    "custom-attributes/issue": "/issue-custom-attributes"

    # Custom Attributess - Values
    "custom-attributes-values/epic": "/epics/custom-attributes-values"
    "custom-attributes-values/userstory": "/userstories/custom-attributes-values"
    "custom-attributes-values/task": "/tasks/custom-attributes-values"
    "custom-attributes-values/issue": "/issues/custom-attributes-values"

    # Webhooks
    "webhooks": "/webhooks"
    "webhooks-test": "/webhooks/%s/test"
    "webhooklogs": "/webhooklogs"
    "webhooklogs-resend": "/webhooklogs/%s/resend"

    # Reports - CSV
    "epics-csv": "/epics/csv?uuid=%s"
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

    # Importers
    "importers-trello-auth-url": "/importers/trello/auth_url"
    "importers-trello-authorize": "/importers/trello/authorize"
    "importers-trello-list-projects": "/importers/trello/list_projects"
    "importers-trello-list-users": "/importers/trello/list_users"
    "importers-trello-import-project": "/importers/trello/import_project"

    "importers-jira-auth-url": "/importers/jira/auth_url"
    "importers-jira-authorize": "/importers/jira/authorize"
    "importers-jira-list-projects": "/importers/jira/list_projects"
    "importers-jira-list-users": "/importers/jira/list_users"
    "importers-jira-import-project": "/importers/jira/import_project"

    "importers-github-auth-url": "/importers/github/auth_url"
    "importers-github-authorize": "/importers/github/authorize"
    "importers-github-list-projects": "/importers/github/list_projects"
    "importers-github-list-users": "/importers/github/list_users"
    "importers-github-import-project": "/importers/github/import_project"

    "importers-asana-auth-url": "/importers/asana/auth_url"
    "importers-asana-authorize": "/importers/asana/authorize"
    "importers-asana-list-projects": "/importers/asana/list_projects"
    "importers-asana-list-users": "/importers/asana/list_users"
    "importers-asana-import-project": "/importers/asana/import_project"
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
    "$tgUserProjectSettingsResourcesProvider",
    "$tgUserSettingsResourcesProvider",
    "$tgSprintsResourcesProvider",
    "$tgEpicsResourcesProvider",
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
