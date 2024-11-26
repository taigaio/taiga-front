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
