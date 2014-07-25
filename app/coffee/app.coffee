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
# File: app.coffee
###

@taiga = taiga = {}

configure = ($routeProvider, $locationProvider, $httpProvider, $provide) ->

    $routeProvider.when("/", {templateUrl: "/partials/projects.html"})
    $routeProvider.when("/create-project", {templateUrl: "/partials/create-project.html"})
    $routeProvider.when("/project/:pslug/", {templateUrl: "/partials/project.html"})
    $routeProvider.when("/project/:pslug/backlog", {templateUrl: "/partials/backlog.html"})
    $routeProvider.when("/project/:pslug/taskboard/:id", {templateUrl: "/partials/taskboard.html"})
    $routeProvider.when("/project/:pslug/search", {templateUrl: "/partials/search.html"})
    $routeProvider.when("/project/:pslug/kanban", {templateUrl: "/partials/kanban.html"})

    # User stories
    $routeProvider.when("/project/:pslug/us/:usref",
                    {templateUrl: "/partials/us-detail.html"})

    $routeProvider.when("/project/:pslug/us/:usref/edit",
                    {templateUrl: "/partials/us-detail-edit.html"})

    # Tasks
    $routeProvider.when("/project/:pslug/tasks/:taskref",
                {templateUrl: "/partials/task-detail.html"})

    $routeProvider.when("/project/:pslug/tasks/:taskref/edit",
                {templateUrl: "/partials/task-detail-edit.html"})

    # Issues
    $routeProvider.when("/project/:pslug/issues", {templateUrl: "/partials/issues.html"})
    $routeProvider.when("/project/:pslug/issues/:issueref",
                        {templateUrl: "/partials/issues-detail.html"})

    $routeProvider.when("/project/:pslug/issues/:issueref/edit",
                        {templateUrl: "/partials/issues-detail-edit.html"})

    # Admin
    $routeProvider.when("/project/:pslug/admin/project-profile/details",
                        {templateUrl: "/partials/admin-project-profile.html"})

    $routeProvider.when("/project/:pslug/admin/project-profile/default-values",
                    {templateUrl: "/partials/admin-project-default-values.html"})

    $routeProvider.when("/project/:pslug/admin/project-profile/features",
                        {templateUrl: "/partials/admin-project-features.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/us-status",
                    {templateUrl: "/partials/admin-project-values-us-status.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/us-points",
                {templateUrl: "/partials/admin-project-values-us-points.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/task-status",
                {templateUrl: "/partials/admin-project-values-task-status.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/issue-status",
                {templateUrl: "/partials/admin-project-values-issue-status.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/issue-types",
            {templateUrl: "/partials/admin-project-values-issue-types.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/issue-priorities",
            {templateUrl: "/partials/admin-project-values-issue-priorities.html"})

    $routeProvider.when("/project/:pslug/admin/project-values/issue-severities",
            {templateUrl: "/partials/admin-project-values-issue-severities.html"})


    $routeProvider.when("/project/:pslug/admin/memberships",
                    {templateUrl: "/partials/admin-memberships.html"})
    # Auth
    $routeProvider.when("/login", {templateUrl: "/partials/login.html"})
    $routeProvider.when("/register", {templateUrl: "/partials/register.html"})
    $routeProvider.when("/forgot-password", {templateUrl: "/partials/forgot-password.html"})
    $routeProvider.when("/change-password",
                        {templateUrl: "/partials/change-password-from-recovery.html"})
    $routeProvider.when("/change-password/:token",
                        {templateUrl: "/partials/change-password-from-recovery.html"})
    $routeProvider.when("/invitation/:token", {templateUrl: "/partials/invitation.html"})

    $routeProvider.otherwise({redirectTo: '/login'})
    $locationProvider.html5Mode(true)

    defaultHeaders = {
        "Content-Type": "application/json"
        "Accept-Language": "en"
    }

    $httpProvider.defaults.headers.delete = defaultHeaders
    $httpProvider.defaults.headers.patch = defaultHeaders
    $httpProvider.defaults.headers.post = defaultHeaders
    $httpProvider.defaults.headers.put = defaultHeaders
    $httpProvider.defaults.headers.get = {}

    # Add next param when user try to access to a secction need auth permissions.
    authHttpIntercept = ($q, $location) ->
        return (promise) ->
            return promise.then null, (response) ->
                if response.status == 401 or response.status == 0
                    nextPath = $location.path()
                    $location.url("/login").search("next=#{nextPath}")
                return $q.reject(response)

    $provide.factory("authHttpIntercept", ["$q", "$location", authHttpIntercept])
    $httpProvider.responseInterceptors.push('authHttpIntercept')


init = ($log, $i18n, $config, $rootscope) ->
    $i18n.initialize($config.get("defaultLanguage"))
    $log.debug("Initialize application")

# Default Value for taiga local config module.
angular.module("taigaLocalConfig", []).value("localconfig", {})

modules = [
    # Main Global Modules
    "taigaBase",
    "taigaCommon",
    "taigaConfig",
    "taigaResources",
    "taigaLocales",
    "taigaAuth",

    # Specific Modules
    "taigaBacklog",
    "taigaTaskboard",
    "taigaKanban"
    "taigaIssues",
    "taigaUserStories",
    "taigaTasks",
    "taigaSearch",
    "taigaAdmin",
    "taigaNavMenu",
    "taigaProject",

    # Vendor modules
    "ngRoute",
    "ngAnimate",
]

# Main module definition
module = angular.module("taiga", modules)

module.config([
    "$routeProvider",
    "$locationProvider",
    "$httpProvider",
    '$provide',
    configure
])

module.run([
    "$log",
    "$tgI18n",
    "$tgConfig",
    "$rootScope",
    init
])
