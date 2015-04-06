class ProfileTabsController
    constructor: (@scope) ->
        @scope.tabs = []

    addTab: (tab) ->
        @scope.tabs.push(tab)

ProfileTabsController.$inject = ["$scope"]

ProfileTabsDirective = () ->
    link = ($scope, $el, $attrs) ->
        $scope.toggleTab = (tab) ->
            _.map $scope.tabs, (tab) => tab.active = false

            tab.active = true

    return {
        scope: {}
        controller: ProfileTabsController
        templateUrl: "profile/profile-tabs.html"
        link: link
        transclude: true
    }

angular.module("taigaProfile")
    .directive("tgProfileTabs", ProfileTabsDirective)
