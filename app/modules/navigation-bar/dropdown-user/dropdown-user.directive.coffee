DropdownUserDirective = (authService, configService, locationService,
        navUrlsService, feedbackService) ->

    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.isFeedbackEnabled = configService.get("feedbackEnabled")
        taiga.defineImmutableProperty(scope.vm, "user", () -> authService.userData)

        scope.vm.logout = ->
            authService.logout()
            locationService.path(navUrlsService.resolve("login"))

        scope.vm.sendFeedback = ->
            feedbackService.sendFeedback()

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
    "tgFeedbackService"
]

angular.module("taigaNavigationBar").directive("tgDropdownUser", DropdownUserDirective)
