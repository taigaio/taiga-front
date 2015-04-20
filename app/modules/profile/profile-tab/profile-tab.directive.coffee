ProfileTabDirective = () ->
    link = ($scope, $el, $attrs, $ctrl) ->
        $scope.tab = {}

        $scope.tab.name = $attrs.tgProfileTab
        $scope.tab.title = $attrs.tabTitle
        $scope.tab.icon = $attrs.tabIcon
        $scope.tab.active = !!$attrs.tabActive

        $ctrl.addTab($scope.tab)

    return {
        scope: {}
        require: "^tgProfileTabs"
        link: link
        transclude: true
        replace: true
        template: """
            <div ng-show="tab.active">
                <ng-transclude></ng-transclude>
            </div>
        """
    }

angular.module("taigaProfile")
    .directive("tgProfileTab", ProfileTabDirective)
