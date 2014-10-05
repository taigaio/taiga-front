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

# Generic function for generate hash from a arbitrary length
# collection of parameters.
taiga.generateHash = (components=[]) ->
    components = _.map(components, (x) -> JSON.stringify(x))
    return hex_sha1(components.join(":"))

taiga.generateUniqueSessionIdentifier = ->
    date = (new Date()).getTime()
    randomNumber = Math.floor(Math.random() * 0x9000000)
    return taiga.generateHash([date, randomNumber])

taiga.sessionId = taiga.generateUniqueSessionIdentifier()


configure = ($routeProvider, $locationProvider, $httpProvider, $provide, $tgEventsProvider, tgLoaderProvider) ->
    $routeProvider.when("/",
        {templateUrl: "/partials/projects.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/",
        {templateUrl: "/partials/project.html"})
    $routeProvider.when("/project/:pslug/backlog",
        {templateUrl: "/partials/backlog.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/taskboard/:sslug",
        {templateUrl: "/partials/taskboard.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/search",
        {templateUrl: "/partials/search.html", reloadOnSearch: false})
    $routeProvider.when("/project/:pslug/kanban",
        {templateUrl: "/partials/kanban.html", resolve: {loader: tgLoaderProvider.add()}})

    # User stories
    $routeProvider.when("/project/:pslug/us/:usref",
        {templateUrl: "/partials/us-detail.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/us/:usref/edit",
        {templateUrl: "/partials/us-detail-edit.html"})

    # Tasks
    $routeProvider.when("/project/:pslug/task/:taskref",
        {templateUrl: "/partials/task-detail.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/task/:taskref/edit",
        {templateUrl: "/partials/task-detail-edit.html"})

    # Wiki
    $routeProvider.when("/project/:pslug/wiki",
        {redirectTo: (params) -> "/project/#{params.pslug}/wiki/home"}, )
    $routeProvider.when("/project/:pslug/wiki/:slug",
        {templateUrl: "/partials/wiki.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/wiki/:slug/edit",
        {templateUrl: "/partials/wiki-edit.html"})

    # Issues
    $routeProvider.when("/project/:pslug/issues",
        {templateUrl: "/partials/issues.html", resolve: {loader: tgLoaderProvider.add()}})
    $routeProvider.when("/project/:pslug/issue/:issueref",
        {templateUrl: "/partials/issues-detail.html"})
    $routeProvider.when("/project/:pslug/issue/:issueref/edit",
        {templateUrl: "/partials/issues-detail-edit.html"})

    # Admin
    $routeProvider.when("/project/:pslug/admin/project-profile/details",
        {templateUrl: "/partials/admin-project-profile.html"})
    $routeProvider.when("/project/:pslug/admin/project-profile/default-values",
        {templateUrl: "/partials/admin-project-default-values.html"})
    $routeProvider.when("/project/:pslug/admin/project-profile/modules",
        {templateUrl: "/partials/admin-project-modules.html"})
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
    $routeProvider.when("/project/:pslug/admin/roles",
        {templateUrl: "/partials/admin-roles.html"})

    # User settings
    $routeProvider.when("/project/:pslug/user-settings/user-profile",
          {templateUrl: "/partials/user-profile.html"})
    $routeProvider.when("/project/:pslug/user-settings/user-change-password",
          {templateUrl: "/partials/user-change-password.html"})
    $routeProvider.when("/project/:pslug/user-settings/user-avatar",
          {templateUrl: "/partials/user-avatar.html"})
    $routeProvider.when("/project/:pslug/user-settings/mail-notifications",
          {templateUrl: "/partials/mail-notifications.html"})
    $routeProvider.when("/change-email/:email_token",
          {templateUrl: "/partials/change-email.html"})

    # Auth
    $routeProvider.when("/login",
        {templateUrl: "/partials/login.html"})
    $routeProvider.when("/register",
        {templateUrl: "/partials/register.html"})
    $routeProvider.when("/forgot-password",
        {templateUrl: "/partials/forgot-password.html"})
    $routeProvider.when("/change-password",
        {templateUrl: "/partials/change-password-from-recovery.html"})
    $routeProvider.when("/change-password/:token",
        {templateUrl: "/partials/change-password-from-recovery.html"})
    $routeProvider.when("/invitation/:token",
        {templateUrl: "/partials/invitation.html"})

    # Errors/Exceptions
    $routeProvider.when("/error",
        {templateUrl: "/partials/error.html"})
    $routeProvider.when("/not-found",
        {templateUrl: "/partials/not-found.html"})

    $routeProvider.otherwise({redirectTo: '/not-found'})
    $locationProvider.html5Mode(true)

    defaultHeaders = {
        "Content-Type": "application/json"
        "Accept-Language": "en"
        "X-Session-Id": taiga.sessionId
    }

    $httpProvider.defaults.headers.delete = defaultHeaders
    $httpProvider.defaults.headers.patch = defaultHeaders
    $httpProvider.defaults.headers.post = defaultHeaders
    $httpProvider.defaults.headers.put = defaultHeaders
    $httpProvider.defaults.headers.get = {
        "X-Session-Id": taiga.sessionId
    }

    $tgEventsProvider.setSessionId(taiga.sessionId)

    # Add next param when user try to access to a secction need auth permissions.
    authHttpIntercept = ($q, $location, $confirm, $navUrls, $lightboxService) ->
        return (promise) ->
            return promise.then null, (response) ->
                if response.status == 0
                    $lightboxService.closeAll()
                    $location.path($navUrls.resolve("error"))
                    $location.replace()
                else if response.status == 401
                    nextPath = $location.path()
                    $location.url($navUrls.resolve("login")).search("next=#{nextPath}")
                return $q.reject(response)

    $provide.factory("authHttpIntercept", ["$q", "$location", "$tgConfirm", "$tgNavUrls",
                                           "lightboxService", authHttpIntercept])
    $httpProvider.responseInterceptors.push('authHttpIntercept')
    $httpProvider.interceptors.push('loaderInterceptor')

    window.checksley.updateValidators({
        linewidth: (val, width) ->
            lines = taiga.nl2br(val).split("<br />")

            valid = _.every lines, (line) ->
                line.length < width

            return valid
    })

    window.checksley.updateMessages("default", {
        linewidth: "The subject must have a maximum size of %s"
    })

init = ($log, $i18n, $config, $rootscope, $auth, $events) ->
    $i18n.initialize($config.get("defaultLanguage"))
    $log.debug("Initialize application")

    if $auth.isAuthenticated()
        $events.setupConnection()

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
    "taigaEvents",

    # Specific Modules
    "taigaRelatedTasks",
    "taigaBacklog",
    "taigaTaskboard",
    "taigaKanban"
    "taigaIssues",
    "taigaUserStories",
    "taigaTasks",
    "taigaWiki",
    "taigaSearch",
    "taigaAdmin",
    "taigaNavMenu",
    "taigaProject",
    "taigaUserSettings",
    "taigaFeedback",
    "taigaPlugins",

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
    "$provide",
    "$tgEventsProvider",
    "tgLoaderProvider",
    configure
])

module.run([
    "$log",
    "$tgI18n",
    "$tgConfig",
    "$rootScope",
    "$tgAuth",
    "$tgEvents",
    init
])
