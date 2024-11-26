###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
mixOf = @.taiga.mixOf
bindOnce = @.taiga.bindOnce

module = angular.module("taigaUserSettings")


#############################################################################
## User settings Controller
#############################################################################

class UserLiveNotificationsController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$tgNavUrls",
        "$tgAuth",
        "tgErrorHandlingService"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @navUrls, @auth, @errorHandlingService) ->
        @scope.sectionName = "USER_SETTINGS.NOTIFICATIONS.LIVE_SECTION_NAME"
        @scope.user = @auth.getUser()
        promise = @.loadInitialData()
        promise.then null, @.onInitialDataError.bind(@)

    loadInitialData: ->
        return @rs.notifyPolicies.list().then (notifyPolicies) =>
            @scope.notifyPolicies = notifyPolicies
            return notifyPolicies

module.controller("UserLiveNotificationsController", UserLiveNotificationsController)


#############################################################################
## User Notifications Directive
#############################################################################

UserLiveNotificationsDirective = () ->
    link = ($scope, $el, $attrs) ->
        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgUserLiveNotifications", UserLiveNotificationsDirective)


#############################################################################
## User Notifications List Directive
#############################################################################

UserLiveNotificationsListDirective = ($repo, $confirm, $compile) ->
    template = _.template("""
        <% _.each(notifyPolicies, function (notifyPolicy, index) { %>
        <div class="policy-table-row" data-index="<%- index %>">
          <div class="policy-table-project"><span><%- notifyPolicy.project_name %></span></div>
          <div class="policy-table-all">
            <div class="button-check">
              <input type="radio"
                     name="policy-<%- notifyPolicy.id %>" id="policy-all-<%- notifyPolicy.id %>"
                     value="2" <% if (notifyPolicy.live_notify_level == 2) { %>checked="checked"<% } %>/>
              <label for="policy-all-<%- notifyPolicy.id %>"
                     translate="USER_SETTINGS.NOTIFICATIONS.OPTION_ALL"></label>
            </div>
          </div>
          <div class="policy-table-involved">
            <div class="button-check">
              <input type="radio"
                     name="policy-<%- notifyPolicy.id %>" id="policy-involved-<%- notifyPolicy.id %>"
                     value="1" <% if (notifyPolicy.live_notify_level == 1) { %>checked="checked"<% } %> />
              <label for="policy-involved-<%- notifyPolicy.id %>"
                     translate="USER_SETTINGS.NOTIFICATIONS.OPTION_INVOLVED"></label>
            </div>
          </div>
          <div class="policy-table-none">
            <div class="button-check">
              <input type="radio"
                     name="policy-<%- notifyPolicy.id %>" id="policy-none-<%- notifyPolicy.id %>"
                     value="3" <% if (notifyPolicy.live_notify_level == 3) { %>checked="checked"<% } %> />
              <label for="policy-none-<%- notifyPolicy.id %>"
                     translate="USER_SETTINGS.NOTIFICATIONS.OPTION_NONE"></label>
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

            $el.on "change", "input[type=radio]", (event) ->
                target = angular.element(event.currentTarget)

                policyIndex = target.parents(".policy-table-row").data('index')
                policy = $scope.notifyPolicies[policyIndex]
                prev_level = policy.live_notify_level
                policy.live_notify_level = parseInt(target.val(), 10)

                onSuccess = ->
                    $confirm.notify("success")

                onError = ->
                    $confirm.notify("error")
                    target.parents(".policy-table-row")
                          .find("input[value=#{prev_level}]")
                          .prop("checked", true)

                $repo.save(policy).then(onSuccess, onError)

        $scope.$on "$destroy", ->
            $el.off()

        bindOnce($scope, $attrs.ngModel, render)

    return {link:link}

module.directive("tgUserLiveNotificationsList", ["$tgRepo", "$tgConfirm", "$compile",
                                             UserLiveNotificationsListDirective])
