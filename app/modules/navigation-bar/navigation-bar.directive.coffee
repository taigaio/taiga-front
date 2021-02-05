###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: navigation-bar/navigation-bar.directive.coffee
###

NavigationBarDirective = (currentUserService, navigationBarService, locationService, navUrlsService, config, feedbackService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))
        taiga.defineImmutableProperty(scope.vm, "isAuthenticated", () -> currentUserService.isAuthenticated())
        taiga.defineImmutableProperty(scope.vm, "isEnabledHeader", () -> navigationBarService.isEnabledHeader())

        scope.vm.publicRegisterEnabled = config.get("publicRegisterEnabled")
        scope.vm.customSupportUrl = config.get("supportUrl")
        scope.vm.isFeedbackEnabled = config.get("feedbackEnabled")

        loadUserPilot = () =>
            userPilotIframe = document.querySelector('#userpilot-resource-centre-frame')

            if userPilotIframe
                scope.$applyAsync () =>
                    userPilotIframeDocument = userPilotIframe.contentWindow.document.body
                    widget = userPilotIframeDocument.querySelector('#widget-title')

                    if widget
                        scope.vm.userPilotTitle = widget.innerText
                        clearInterval(userPilotInterval)

        attempts = 10

        if window.TAIGA_USER_PILOT_TOKEN
            scope.vm.userPilotTitle = 'Help center'
            scope.vm.userpilotEnabled = true

            userPilotInterval = setInterval () =>
                loadUserPilot()
                attempts--

                if !attempts
                    clearInterval(userPilotInterval)
            , 1000

        scope.vm.login = ->
            nextUrl = encodeURIComponent(locationService.url())
            locationService.url(navUrlsService.resolve("login"))
            locationService.search({next: nextUrl})

        scope.vm.sendFeedback = () ->
            feedbackService.sendFeedback()

        window._taigaSendFeedback = scope.vm.sendFeedback

        scope.$on "$routeChangeSuccess", () ->
            scope.vm.active = null
            path = locationService.path()

            switch path
                when "/"
                    scope.vm.active = 'dashboard'
                when "/discover"
                    scope.vm.active = 'discover'
                when "/notifications"
                    scope.vm.active = 'notifications'
                when "/projects/"
                    scope.vm.active = 'projects'
                else
                    if path.startsWith('/project')
                        scope.vm.active = 'project'

    directive = {
        templateUrl: "navigation-bar/navigation-bar.html"
        scope: {}
        link: link
    }

    return directive

NavigationBarDirective.$inject = [
    "tgCurrentUserService",
    "tgNavigationBarService",
    "$tgLocation",
    "$tgNavUrls",
    "$tgConfig",
    "tgFeedbackService"
]

angular.module("taigaNavigationBar").directive("tgNavigationBar", NavigationBarDirective)
