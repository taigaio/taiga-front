ProfileTabDirective = () ->
    link = (scope, element, attrs, ctrl, transclude) ->
        scope.tab = {}

        scope.tab.name = attrs.tgProfileTab
        scope.tab.title = attrs.tabTitle
        scope.tab.icon = attrs.tabIcon
        scope.tab.active = !!attrs.tabActive

        ctrl.addTab(scope.tab)

        scope.$watch "tab.active", (active) ->
            if active
                transclude scope, (clone, scope) ->
                    element.append(clone)
            else
                element.children().each (idx, elm) ->
                    scope.$$childHead.$destroy()
                    elm.remove()

    return {
        scope: {}
        require: "^tgProfileTabs"
        link: link
        transclude: true
        replace: true
    }

angular.module("taigaProfile")
    .directive("tgProfileTab", ProfileTabDirective)
