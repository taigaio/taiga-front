###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

PromoteToUsButtonDirective = ($rootScope, $rs, $confirm, $translate) ->
    link = ($scope, $el, $attrs, $model) ->
        itemType = null

        save = (item, askResponse) ->
            data = {
                project: item.project
            }

            onSuccess = (response) ->
                askResponse.finish()
                $confirm.notify("success")
                $rootScope.$broadcast("promote-#{itemType}-to-us:success", response.data[0])

            onError = ->
                askResponse.finish()
                $confirm.notify("error")

            $rs[item._name].promoteToUserStory(item.id, item.project).then(onSuccess, onError)

        $el.on "click", ".promote-button", (event) ->
            event.preventDefault()
            item = $model.$modelValue
            itemType = _.get({ tasks: 'task', issues: 'issue' }, item._name)

            ctx = "COMMON.CONFIRM_PROMOTE.#{itemType.toUpperCase()}"
            title = $translate.instant("#{ctx}.TITLE")
            message = $translate.instant("#{ctx}.MESSAGE")
            subtitle = item.subject
            $confirm.ask(title, subtitle, message).then (response) ->
                save(item, response)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        restrict: "AE"
        require: "ngModel"
        templateUrl: "components/promote-to-us/promote-to-us.html"
        link: link
    }

angular.module("taigaComponents").directive("tgPromoteToUsButton",
    ["$rootScope", "$tgResources", "$tgConfirm", "$translate", PromoteToUsButtonDirective])