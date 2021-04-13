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
