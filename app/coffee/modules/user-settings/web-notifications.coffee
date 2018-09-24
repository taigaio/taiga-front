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
# File: modules/user-settings/live-notifications.coffee
###

taiga = @.taiga
mixOf = @.taiga.mixOf
bindOnce = @.taiga.bindOnce

module = angular.module("taigaUserSettings")


#############################################################################
## User Web Notifications Controller
#############################################################################

class UserWebNotificationsController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$tgResources",
        "$tgAuth"
    ]

    constructor: (@scope, @rs, @auth) ->
        @scope.sectionName = "USER_SETTINGS.EVENTS.SECTION_NAME"
        @scope.user = @auth.getUser()
        promise = @.loadInitialData()
        promise.then null, @.onInitialDataError.bind(@)

    loadInitialData: ->
        return @rs.notifyPolicies.list().then (notifyPolicies) =>
            @scope.notifyPolicies = notifyPolicies
            return notifyPolicies

module.controller("UserWebNotificationsController", UserWebNotificationsController)


#############################################################################
## User Web Notifications Directive
#############################################################################

UserWebNotificationsDirective = () ->
    link = ($scope, $el, $attrs) ->
        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgUserWebNotifications", UserWebNotificationsDirective)


#############################################################################
## User Web Notifications List Directive
#############################################################################

UserWebNotificationsListDirective = ($repo, $confirm, $compile) ->
    template = _.template("""
        <% _.each(notifyPolicies, function (notifyPolicy, index) { %>
        <div class="policy-table-row">
          <div class="policy-table-project"><span><%- notifyPolicy.project_name %></span></div>
          <div class="policy-table-all">
            <div class="check" data-index="<%- index %>">
              <input type="checkbox"
                <% if(notifyPolicy.web_notify_level) { %> checked="checked" <% } %>
                name="policy-<%- notifyPolicy.id %>" id="policy-<%- notifyPolicy.id %>"/>
              <div></div>
              <span class="check-text check-yes" translate="COMMON.YES"></span>
              <span class="check-text check-no"" translate="COMMON.NO"></span>
            </div>
          </div>
        </div>
        <% }) %>
    """)

    link = ($scope, $el, $attrs) ->
        render = ->
            $el.off()

            ctx = {notifyPolicies: $scope.notifyPolicies}
            html = template(ctx)

            $el.html($compile(html)($scope))

            $el.on "click", ".check", (event) ->
                target = angular.element(event.currentTarget)
                policyIndex = target.data('index')
                policy = $scope.notifyPolicies[policyIndex]
                policy.web_notify_level = !policy.web_notify_level

                onSuccess = ->
                    $confirm.notify("success")
                    target.find("input").prop("checked", policy.web_notify_level)

                onError = ->
                    $confirm.notify("error")

                $repo.save(policy).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

        bindOnce($scope, $attrs.ngModel, render)

    return {link:link}

module.directive("tgUserWebNotificationsList",
["$tgRepo", "$tgConfirm", "$compile", UserWebNotificationsListDirective])
