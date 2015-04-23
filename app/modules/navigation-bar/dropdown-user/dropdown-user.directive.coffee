DropdownUserDirective = (authService, configService, locationService,
        navUrlsService, feedbackService) ->

    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        scope.vm.user = authService.getUser()
        scope.vm.isFeedbackEnabled = configService.get("feedbackEnabled")

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

angular.module("taigaNavigationBar").directive("tgDropdownUser",
    ["$tgAuth", "$tgConfig", "$tgLocation", "$tgNavUrls", "tgFeedback",
    DropdownUserDirective])
