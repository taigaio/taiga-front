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

class UserNotificationsController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$tgConfirm",
        "$tgResources",
        "$tgAuth",
        "$tgConfig",
        "tgResources",
        "tgCurrentUserService",
        "$translate"
    ]

    constructor: (@scope, @confirm, @rs, @auth, @config, @resources, @currentUserService, @translate) ->
        @scope.sectionName = "USER_SETTINGS.NOTIFICATIONS.SECTION_NAME"
        @scope.user = @auth.getUser()
        promise = @.loadInitialData()
        promise.then null, @.onInitialDataError.bind(@)

        @.isSaas = @config.get("isSaas")
        @.onPremiseSubscribed = false
        @.loadPremise = false

    subscribed: ->
        @.loadPremise = true
        @resources.onPremise.subscribeOnPremiseNewsletter(
            {
                "email": @currentUserService.getUser().get('email'),
                "full_name": @currentUserService.getUser().get('full_name'),
                "origin_form": 'Newsletter sign-up settings'
            }
        ).then () =>
            text = @translate.instant("PROJECT.NEWSLETTER_OPENING.SAVED_PREFERENCE")

            @confirm.notify("success", "Your preferences have been save successfully")
            @.onPremiseSubscribed = true
            @.loadPremise = false
            @resources.user.getUserStorage('dont_ask_premise_newsletter')
                .then (storageState) =>
                    @resources.user.setUserStorage('dont_ask_premise_newsletter', true)
                .catch (storageError) =>
                    if storageError.status = 404
                        @resources.user.createUserStorage('dont_ask_premise_newsletter', false)

        .catch () =>
            @confirm.notify("light-error", "")
            @.loadPremise = false

    loadInitialData: ->
        return @rs.notifyPolicies.list().then (notifyPolicies) =>
            @scope.notifyPolicies = notifyPolicies
            return notifyPolicies

module.controller("UserNotificationsController", UserNotificationsController)


#############################################################################
## User Notifications Directive
#############################################################################

UserNotificationsDirective = () ->
    link = ($scope, $el, $attrs) ->
        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgUserNotifications", UserNotificationsDirective)


#############################################################################
## User Notifications List Directive
#############################################################################

UserNotificationsListDirective = ($repo, $confirm, $compile) ->
    template = _.template("""
        <% _.each(notifyPolicies, function (notifyPolicy, index) { %>
        <div class="policy-table-row" data-index="<%- index %>">
          <div class="policy-table-project"><span><%- notifyPolicy.project_name %></span></div>
          <div class="policy-table-all">
            <div class="button-check">
              <input type="radio"
                     name="policy-<%- notifyPolicy.id %>" id="policy-all-<%- notifyPolicy.id %>"
                     value="2" <% if (notifyPolicy.notify_level == 2) { %>checked="checked"<% } %>/>
              <label for="policy-all-<%- notifyPolicy.id %>"
                     translate="USER_SETTINGS.NOTIFICATIONS.OPTION_ALL"></label>
            </div>
          </div>
          <div class="policy-table-involved">
            <div class="button-check">
              <input type="radio"
                     name="policy-<%- notifyPolicy.id %>" id="policy-involved-<%- notifyPolicy.id %>"
                     value="1" <% if (notifyPolicy.notify_level == 1) { %>checked="checked"<% } %> />
              <label for="policy-involved-<%- notifyPolicy.id %>"
                     translate="USER_SETTINGS.NOTIFICATIONS.OPTION_INVOLVED"></label>
            </div>
          </div>
          <div class="policy-table-none">
            <div class="button-check">
              <input type="radio"
                     name="policy-<%- notifyPolicy.id %>" id="policy-none-<%- notifyPolicy.id %>"
                     value="3" <% if (notifyPolicy.notify_level == 3) { %>checked="checked"<% } %> />
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
                prev_level = policy.notify_level
                policy.notify_level = parseInt(target.val(), 10)

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

module.directive("tgUserNotificationsList", ["$tgRepo", "$tgConfirm", "$compile",
                                             UserNotificationsListDirective])
