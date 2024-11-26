###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

DropdownUserDirective = (authService, configService, locationService,
        navUrlsService, $rootScope) ->

    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.isFeedbackEnabled = configService.get("feedbackEnabled")
        scope.vm.customSupportUrl = configService.get("supportUrl")
        taiga.defineImmutableProperty(scope.vm, "user", () -> authService.userData)

        scope.vm.logout = ->
            authService.logout()
            locationService.url(navUrlsService.resolve("discover"))
            locationService.search({})

        scope.vm.userSettingsPlugins = _.filter($rootScope.userSettingsPlugins, {userMenu: true})

    directive = {
        templateUrl: "navigation-bar/dropdown-user/dropdown-user.html"
        scope: {}
        link: link
    }

    return directive

DropdownUserDirective.$inject = [
    "$tgAuth",
    "$tgConfig",
    "$tgLocation",
    "$tgNavUrls",
    "$rootScope"
]

angular.module("taigaNavigationBar").directive("tgDropdownUser", DropdownUserDirective)
