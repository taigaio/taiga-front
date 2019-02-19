###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: components/promote-to-us/promote-to-us.directive.coffee
###

PromoteToUsButtonDirective = ($rootScope, $repo, $confirm, $translate) ->
    link = ($scope, $el, $attrs, $model) ->
        itemType = null

        save = (item, askResponse) ->
            data = {
                "generated_from_#{itemType}": item.id,
                project: item.project,
                subject: item.subject
                description: item.description
                tags: item.tags
                is_blocked: item.is_blocked
                blocked_note: item.blocked_note
                due_date: item.due_date
            }

            onSuccess = ->
                askResponse.finish()
                $confirm.notify("success")
                $rootScope.$broadcast("promote-#{itemType}-to-us:success")

            onError = ->
                askResponse.finish()
                $confirm.notify("error")

            $repo.create("userstories", data).then(onSuccess, onError)

        $el.on "click", "a", (event) ->
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
    ["$rootScope", "$tgRepo", "$tgConfirm", "$translate", PromoteToUsButtonDirective])