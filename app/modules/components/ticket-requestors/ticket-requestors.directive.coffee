###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

TicketRequestorsDirective = ($rootscope, $confirm, $repo, $modelTransform, $compile,
$translate, $lightboxFactory) ->
    link = ($scope, $el, $attrs, $model) ->
        $scope.visibleRequestorsCount = 4
        $scope.displayHidden = false

        $scope.toggleFold = () ->
            $scope.displayHidden = !$scope.displayHidden

        save = (requestors) ->
            $scope.loading = true
            transform = $modelTransform.save (item) ->
                item.requestors = requestors
                return item

            transform.then ->
                result = $rootscope.$broadcast("object:updated")
            transform.then null, ->
                $confirm.notify("error")
            transform.finally ->
                $scope.loading = false

        $scope.addRequestors = () ->
            onClose = (requestors) ->
                save(requestors)

            item = _.clone($model.$modelValue, false)
            $lightboxFactory.create(
                'tg-lb-select-user',
                {
                    "class": "lightbox lightbox-select-user",
                },
                {
                    "currentUsers": item.requestors,
                    "activeUsers": $scope.activeUsers,
                    "onClose": onClose,
                    "lbTitle": $translate.instant("COMMON.REQUESTORS.ADD"),
                }
            )

        $el.on "click", ".user-list-single", (event) ->
            return if not $scope.isAdmin()
            event.stopPropagation()
            $scope.addRequestors()

        $el.on "click", ".remove-user", (event) ->
            return if not $scope.isAdmin()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            requestorId = target.data("user-id")

            title = $translate.instant("COMMON.REQUESTORS.TITLE_LIGHTBOX_DELETE_REQUESTOR")
            message = $scope.usersById[requestorId].full_name_display

            $confirm.askOnDelete(title, message).then (askResponse) ->
                askResponse.finish()

                requestors = _.clone($model.$modelValue.requestors, false)
                requestors = _.pull(requestors, requestorId)

                deleteRequestor(requestors)

        deleteRequestor = (requestors) ->
            $scope.loading = true
            transform = $modelTransform.save (item) ->
                item.requestors = requestors
                return item

            transform.then () ->
                item = $modelTransform.getObj()
                $attrs.ngModel = item
                $rootscope.$broadcast("object:updated")
            transform.then null, ->
                item.revert()
                $confirm.notify("error")
            transform.finally ->
                $scope.loading = false

        render = (requestorIds) ->
            requestors = _.map(requestorIds, (requestorId) -> $scope.usersById[requestorId])
            $scope.requestors = _.compact(requestors)

        $scope.$watch $attrs.ngModel, (item, currentItem) ->
            return if not item?
            render(item.requestors)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        scope: true,
        templateUrl: "components/ticket-requestors/ticket-requestors.html",
        link: link,
        require: "ngModel"
    }

angular.module('taigaComponents').directive("tgRequestors", ["$rootScope", "$tgConfirm",
"$tgRepo", "$tgQueueModelTransformation", "$compile", "$translate",
"tgLightboxFactory", TicketRequestorsDirective])
