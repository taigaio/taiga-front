###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaBase", [])

#############################################################################
## Main Directive
#############################################################################

TaigaMainDirective = ($rootscope, $window) ->
    link = ($scope, $el, $attrs) ->
        $window.onresize = () ->
            $rootscope.$broadcast("resize")

    return {link:link}

module.directive("tgMain", ["$rootScope", "$window", TaigaMainDirective])

#############################################################################
## Navigation
#############################################################################

urls = {
    "home": "/"
    "projects": "/projects"
    "error": "/error"
    "not-found": "/not-found"
    "permission-denied": "/permission-denied"

    "discover": "/discover"
    "discover-search": "/discover/search"

    "login": "/login"
    "forgot-password": "/forgot-password"
    "change-password": "/change-password/:token"
    "change-email": "/change-email/:token"
    "verified-email": "/change-email/:token"
    "cancel-account": "/cancel-account/:token"
    "register": "/register"
    "invitation": "/invitation/:token"
    "create-project": "/project/new"
    "create-project-scrum": "/project/new/scrum"
    "create-project-kanban": "/project/new/kanban"
    "create-project-duplicate": "/project/new/duplicate"
    "create-project-import": "/project/new/import"
    "create-project-import-platform": "/project/new/import/:platform"

    "profile": "/profile"
    "user-profile": "/profile/:username"

    "blocked-project": "/blocked-project/:project"
    "project": "/project/:project"
    "project-detail-ref": "/project/:project/t/:ref"
    "project-backlog": "/project/:project/backlog"
    "project-taskboard": "/project/:project/taskboard/:sprint"
    "project-kanban": "/project/:project/kanban"
    "project-issues": "/project/:project/issues"
    "project-epics": "/project/:project/epics"
    "project-search": "/project/:project/search"
    "project-timeline": "/project/:project/timeline"

    "project-epics-detail": "/project/:project/epic/:ref"
    "project-userstories-detail": "/project/:project/us/:ref"
    "project-tasks-detail": "/project/:project/task/:ref"
    "project-issues-detail": "/project/:project/issue/:ref"

    "project-wiki": "/project/:project/wiki"
    "project-wiki-list": "/project/:project/wiki-list"
    "project-wiki-page": "/project/:project/wiki/:slug"

    # Team
    "project-team": "/project/:project/team"

    # Admin
    "project-admin-home": "/project/:project/admin/project-profile/details"
    "project-admin-project-profile-details": "/project/:project/admin/project-profile/details"
    "project-admin-project-profile-default-values": "/project/:project/admin/project-profile/default-values"
    "project-admin-project-profile-modules": "/project/:project/admin/project-profile/modules"
    "project-admin-project-profile-export": "/project/:project/admin/project-profile/export"
    "project-admin-project-profile-reports": "/project/:project/admin/project-profile/reports"

    "project-admin-project-values-status": "/project/:project/admin/project-values/status"
    "project-admin-project-values-points": "/project/:project/admin/project-values/points"
    "project-admin-project-values-priorities": "/project/:project/admin/project-values/priorities"
    "project-admin-project-values-severities": "/project/:project/admin/project-values/severities"
    "project-admin-project-values-types": "/project/:project/admin/project-values/types"
    "project-admin-project-values-custom-fields": "/project/:project/admin/project-values/custom-fields"
    "project-admin-project-values-tags": "/project/:project/admin/project-values/tags"
    "project-admin-project-values-due-dates": "/project/:project/admin/project-values/due-dates"
    "project-admin-project-values-kanban-power-ups": "/project/:project/admin/project-values/kanban-power-ups"

    "project-admin-memberships": "/project/:project/admin/memberships"
    "project-admin-roles": "/project/:project/admin/roles"
    "project-admin-third-parties-webhooks": "/project/:project/admin/third-parties/webhooks"
    "project-admin-third-parties-github": "/project/:project/admin/third-parties/github"
    "project-admin-third-parties-gitlab": "/project/:project/admin/third-parties/gitlab"
    "project-admin-third-parties-bitbucket": "/project/:project/admin/third-parties/bitbucket"
    "project-admin-third-parties-gogs": "/project/:project/admin/third-parties/gogs"
    "project-admin-contrib": "/project/:project/admin/contrib/:plugin"

    # User settings
    "user-settings-user-profile": "/user-settings/user-profile"
    "user-settings-user-change-password": "/user-settings/user-change-password"
    "user-settings-user-avatar": "/user-settings/user-avatar"
    "user-settings-user-project-settings": "/user-settings/user-project-settings"
    "user-settings-mail-notifications": "/user-settings/mail-notifications"
    "user-settings-live-notifications": "/user-settings/live-notifications"
    "user-settings-web-notifications": "/user-settings/web-notifications"
    "user-settings-contrib": "/user-settings/contrib/:plugin"

    "notifications": "/notifications"
}

init = ($log, $navurls) ->
    $log.debug "Initialize navigation urls"
    $navurls.update(urls)

module.run(["$log", "$tgNavUrls", init])
