ProfileTabDirective = () ->
    link = (scope, element, attrs, ctrl, transclude) ->
        scope.tab = {}

        attrs.$observe "tabTitle", (title) ->
            scope.tab.title = title

        scope.tab.name = attrs.tgProfileTab
        scope.tab.icon = attrs.tabIcon
        scope.tab.active = !!attrs.tabActive

        if scope.$eval(attrs.tabDisabled) != true
            ctrl.addTab(scope.tab)

    return {
        templateUrl: "profile/profile-tab/profile-tab.html",
        scope: {},
        require: "^tgProfileTabs",
        link: link,
        transclude: true
    }

angular.module("taigaProfile")
    .directive("tgProfileTab", ProfileTabDirective)
