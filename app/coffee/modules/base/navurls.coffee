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
# File: modules/base/navurl.coffee
###


taiga = @.taiga
trim = @.taiga.trim
bindOnce = @.taiga.bindOnce

class NavigationUrlsService extends taiga.Service
    constructor: ->
        @.urls = {}

    update: (urls) ->
        @.urls = _.merge({}, @.urls, urls or {})

    resolve: (name) ->
        return @.urls[name]


NavigationUrlsDirective = ($navurls, $auth, $q, $location) ->
    # Example:
    # link(tg-nav="project-backlog:project='sss',")

    # bindOnce version that uses $q for offer
    # promise based api
    bindOnceP = ($scope, attr) ->
        defered = $q.defer()
        bindOnce $scope, attr, (v) ->
            defered.resolve(v)
        return defered.promise

    parseNav = (data, $scope) ->
        [name, params] = _.map(data.split(":"), trim)
        params = _.map(params.split(","), trim)
        values = _.map(params, (x) -> trim(x.split("=")[1]))
        promises = _.map(values, (x) -> bindOnceP($scope, x))

        return $q.all.apply($q, promises).then ->
            options = {}
            for item in params
                [key, value] = _.map(item.split("="), trim)
                options[key] = $scope.$eval(value)
            return [name, options]

    formatUrl = (url, ctx={}) ->
        replacer = (match) ->
            match = trim(match, ":")
            return ctx[match] or "undefined"
        return url.replace(/(:\w+)/g, replacer)

    link = ($scope, $el, $attrs) ->
        $el.on "click", (event) ->
            event.preventDefault()

            parseNav($attrs.tgNav, $scope).then (result) ->
                [name, options] = result
                user = $auth.getUser()
                options.user = user.username if user

                url = $navurls.resolve(name)
                fullUrl = formatUrl(url, options)
                $location.url(fullUrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaBase")
module.service("$tgNavUrls", NavigationUrlsService)
module.directive("tgNav", ["$tgNavUrls", "$tgAuth", "$q", "$location", NavigationUrlsDirective])


