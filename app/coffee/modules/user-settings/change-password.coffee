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
# File: modules/user-settings/change-password.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
debounce = @.taiga.debounce

module = angular.module("taigaUserSettings")


#############################################################################
## User ChangePassword Controller
#############################################################################

class UserChangePasswordController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        "$translate"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @navUrls,
                  @auth, @translate) ->
        @scope.sectionName = @translate.instant("CHANGE_PASSWORD.SECTION_NAME")
        @scope.user = @auth.getUser()

module.controller("UserChangePasswordController", UserChangePasswordController)


#############################################################################
## User ChangePassword Directive
#############################################################################

UserChangePasswordDirective = ($rs, $confirm, $loading, $translate) ->
    link = ($scope, $el, $attrs, ctrl) ->
        form = new checksley.Form($el.find("form"))

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            if $scope.newPassword1 != $scope.newPassword2
                $confirm.notify('error', $translate.instant("CHANGE_PASSWORD.ERROR_PASSWORD_MATCH"))
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $rs.userSettings.changePassword($scope.currentPassword, $scope.newPassword1)
            promise.then =>
                currentLoading.finish()
                $confirm.notify('success')

            promise.then null, (response) =>
                currentLoading.finish()
                $confirm.notify('error', response.data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link
    }

module.directive("tgUserChangePassword", ["$tgResources", "$tgConfirm", "$tgLoading", "$translate", UserChangePasswordDirective])
