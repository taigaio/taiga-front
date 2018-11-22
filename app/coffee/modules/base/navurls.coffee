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
# File: modules/base/navurls.coffee
###

taiga = @.taiga
trim = @.taiga.trim
bindOnce = @.taiga.bindOnce

module = angular.module("taigaBase")


#############################################################################
## Navigation Urls Service
#############################################################################

class NavigationUrlsService extends taiga.Service
    constructor: ->
        @.urls = {}

    update: (urls) ->
        @.urls = _.merge({}, @.urls, urls or {})

    formatUrl: (url, ctx={}) ->
        replacer = (match) ->
            match = trim(match, ":")
            return ctx[match] or "undefined"
        return url.replace(/(:\w+)/g, replacer)

    resolve: (name, ctx) ->
        url = @.urls[name]
        return "" if not url
        return @.formatUrl(url, ctx) if ctx
        return url

module.service("$tgNavUrls", NavigationUrlsService)


#############################################################################
## Navigation Urls Directive
#############################################################################

NavigationUrlsDirective = ($navurls, $auth, $q, $location, lightboxService, tgSections) ->
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
        if params
            # split by 'xxx='
            # example
            # project=vm.timeline.getIn(['data', 'project', 'slug']), ref=vm.timeline.getIn(['obj', 'ref'])
            # ["", "project", "vm.timeline.getIn(['data', 'project', 'slug']), ", "ref", "vm.timeline.getIn(['obj', 'ref'])"]
            result = params.split(/(\w+)=/)

            # remove empty string
            result = _.filter result, (str) -> return str.length

            # remove , at the end of the string
            result = _.map result, (str) -> return trim(str.replace(/,$/g, ''))

            params = []
            index = 0

            # ['param1', 'value'] => [{'param1': 'value'}]
            while index < result.length
                obj = {}
                obj[result[index]] = result[index + 1]
                params.push obj
                index = index + 2
        else
            params = []

        values = _.map params, (param) -> _.values(param)[0]
        promises = _.map(values, (x) -> bindOnceP($scope, x))

        return $q.all(promises).then ->
            options = {}
            for param in params
                key = Object.keys(param)[0]
                value = param[key]

                options[key] = $scope.$eval(value)
            return [name, options]

    link = ($scope, $el, $attrs) ->
        if $el.is("a")
            $el.attr("href", "#")

        $el.on "mouseenter", (event) ->
            target = $(event.currentTarget)

            if !target.data("fullUrl") || $attrs.tgNavGetParams != target.data("params")
                parseNav($attrs.tgNav, $scope).then (result) ->
                    [name, options] = result
                    user = $auth.getUser()
                    options.user = user.username if user

                    if options['section']
                        sections = tgSections.list()
                        section = _.find(sections, {"id": options['section']})
                        name = "#{name}-#{section.path}"

                    url = $navurls.resolve(name)

                    fullUrl = $navurls.formatUrl(url, options)

                    if $attrs.tgNavGetParams
                        getURLParams = JSON.parse($attrs.tgNavGetParams)
                        getURLParamsStr = $.param(getURLParams)
                        fullUrl = "#{fullUrl}?#{getURLParamsStr}"

                        target.data("params", $attrs.tgNavGetParams)

                    target.data("fullUrl", fullUrl)

                    if target.is("a")
                        target.attr("href", fullUrl)

                    $el.on "click", (event) ->
                        if event.metaKey || event.ctrlKey
                            return

                        event.preventDefault()
                        target = $(event.currentTarget)

                        if target.hasClass('noclick')
                            return

                        fullUrl = target.data("fullUrl")

                        switch event.which
                            when 1
                                $location.url(fullUrl)
                                $scope.$apply()
                            when 2
                                window.open fullUrl

                        lightboxService.closeAll()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgNav",
    ["$tgNavUrls", "$tgAuth", "$q", "$tgLocation", "lightboxService", "$tgSections", NavigationUrlsDirective])
