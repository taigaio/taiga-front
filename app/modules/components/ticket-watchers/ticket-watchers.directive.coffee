###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

WatchersDirective = ($rootscope, $confirm, $repo, $modelTransform, $template,
$compile, $translate, $currentUserService) ->
    link = ($scope, $el, $attrs) ->
        $scope.visibleWatchersCount = 4
        $scope.displayHidden = false
        $scope.isAuthenticated = !!$currentUserService.getUser()

        isEditable = ->
            return $scope.project?.my_permissions?.indexOf($attrs.requiredPerm) != -1

        render = () ->
            watchersIds = _.clone($scope.vm.item?.watchers, false)
            watchers = _.map(watchersIds, (watcherId) -> $scope.usersById[watcherId])
            watchers = _.filter watchers, (it) -> return !!it
            $scope.vm.watchers = _.compact(watchers)
            $scope.isEditable = isEditable()

        $scope.toggleFold = () ->
            $scope.displayHidden = !$scope.displayHidden

        $el.on "click", ".user-list-single", (event) ->
            return if not isEditable()
            event.stopPropagation()
            $scope.vm.openWatchers()

        $el.on "click", ".remove-user", (event) ->
            return if not isEditable()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            watcherId = target.data("watcher-id")

            title = $translate.instant("COMMON.WATCHERS.TITLE_LIGHTBOX_DELETE_WARTCHER")
            message = $scope.usersById[watcherId].full_name_display

            $confirm.askOnDelete(title, message).then (askResponse) =>
                askResponse.finish()
                $scope.vm.deleteWatcher(watcherId)

        $scope.$on "watcher:added", (ctx, watcherId) ->
            watchersIds = _.clone($scope.item.watchers, false)
            watchersIds.push(watcherId)
            watchersIds = _.uniq(watchers)
            $scope.vm.save(watchersIds)

        $scope.$on "watchers:selected", (ctx, watchersIds) ->
            $scope.vm.save(watchersIds)

        $scope.$watch "vm.item" , (item) ->
            return if not item
            render()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        scope: true,
        controller: "TicketWatchersController",
        bindToController: {
            item: "=",
            onWatch: "=",
            onUnwatch: "=",
            activeUsers: "="
        }
        controllerAs: "vm",
        templateUrl: "components/ticket-watchers/ticket-watchers.html",
        link: link
    }

WatchersDirective.$inject = [
    "$rootScope"
    "$tgConfirm"
    "$tgRepo"
    "$tgQueueModelTransformation"
    "$tgTemplate"
    "$compile"
    "$translate"
    "tgCurrentUserService"
]

angular.module("taigaComponents").directive("tgWatchers", WatchersDirective)