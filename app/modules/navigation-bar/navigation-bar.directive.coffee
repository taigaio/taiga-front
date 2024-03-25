###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
