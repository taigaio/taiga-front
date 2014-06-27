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

configure = ($routeProvider, $locationProvider, $httpProvider, $provide, $compileProvider, $gmUrlsProvider) ->
    $routeProvider.when("/project/:pslug/backlog", {templateUrl: "/partials/backlog.html"})
    $routeProvider.when("/project/:pslug/taskboard/:id", {templateUrl: "/partials/taskboard.html"})
    $routeProvider.when("/project/:pslug/issues", {templateUrl: "/partials/issues.html"})
    $routeProvider.when("/project/:pslug/search", {templateUrl: "/partials/search.html"})

    $routeProvider.when("/login", {templateUrl: "/partials/login.html"})
    $routeProvider.when("/register", {templateUrl: "/partials/register.html"})

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

    # authHttpIntercept = ($q, $location) ->
    #     return (promise) ->
    #         return promise.then null, (response) ->
    #             if response.status == 401 or response.status == 0
    #                 $location.url("/login?next=#{$location.path()}")
    #             return $q.reject(response)
    # $provide.factory("authHttpIntercept", ["$q", "$location", authHttpIntercept])
    # $httpProvider.responseInterceptors.push('authHttpIntercept')


init = ($log, $i18n, $config, $rootscope) ->
    $i18n.initialize($config.get("defaultLanguage"))
    $log.debug("Initialize application")

# Default Value for taiga local config module.
angular.module("taigaLocalConfig", []).value("localconfig", {})

# Default constructor for common module
angular.module("taigaCommon", [])

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
    "taigaIssues",
    "taigaSearch",

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
    configure
])

module.run([
    "$log",
    "$tgI18n",
    "$tgConfig",
    "$rootScope",
    init
])
