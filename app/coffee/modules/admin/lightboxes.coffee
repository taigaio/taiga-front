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
# File: modules/admin/lightboxes.coffee
###

taiga = @.taiga
debounce = @.taiga.debounce

module = angular.module("taigaKanban")

#############################################################################
## Warning message directive
#############################################################################

LightboxAddMembersWarningMessageDirective = () ->
    return {
          templateUrl: "admin/memberships-warning-message.html"
          scope: {
              project: "="
          }
    }

module.directive("tgLightboxAddMembersWarningMessage", [LightboxAddMembersWarningMessageDirective])


#############################################################################
## Transfer project ownership
#############################################################################

LbRequestOwnershipDirective = (lightboxService, rs, confirmService, $translate) ->
    return {
        link: (scope, el) ->
            lightboxService.open(el)

            scope.request = () ->
                scope.loading = true

                rs.projects.transferRequest(scope.projectId).then () ->
                    scope.loading = false

                    lightboxService.close(el)

                    confirmService.notify("success", $translate.instant("ADMIN.PROJECT_PROFILE.REQUEST_OWNERSHIP_SUCCESS"))

        templateUrl: "common/lightbox/lightbox-request-ownership.html"
    }

module.directive('tgLbRequestOwnership', [
    "lightboxService",
    "tgResources",
    "$tgConfirm",
    "$translate",
    LbRequestOwnershipDirective])

class ChangeOwnerLightboxController
    constructor: (@rs, @lightboxService, @confirm, @translate) ->
        @.users = []
        @.q = ""
        @.commentOpen = false

    limit: 3

    normalizeString: (normalizedString) ->
        normalizedString = normalizedString.replace("Á", "A").replace("Ä", "A").replace("À", "A")
        normalizedString = normalizedString.replace("É", "E").replace("Ë", "E").replace("È", "E")
        normalizedString = normalizedString.replace("Í", "I").replace("Ï", "I").replace("Ì", "I")
        normalizedString = normalizedString.replace("Ó", "O").replace("Ö", "O").replace("Ò", "O")
        normalizedString = normalizedString.replace("Ú", "U").replace("Ü", "U").replace("Ù", "U")
        return normalizedString

    filterUsers: (user) ->
        username = user.full_name_display.toUpperCase()
        username = @.normalizeString(username)
        text = @.q.toUpperCase()
        text = @.normalizeString(text)

        return _.includes(username, text)

    getUsers: () ->
        if !@.users.length && !@.q.length
            users =  @.activeUsers
        else
            users = @.users

        users = users.slice(0, @.limit)
        users = _.reject(users, {"selected": true})

        return _.reject(users, {"id": @.currentOwnerId})

    userSearch: () ->
        @.users = @.activeUsers

        @.selected = _.find(@.users, {"selected": true})

        @.users = _.filter(@.users, @.filterUsers.bind(this)) if @.q

    selectUser: (user) ->
        @.activeUsers = _.map @.activeUsers, (user) ->
            user.selected = false

            return user

        user.selected = true

        @.userSearch()

    submit: () ->
        @.loading = true
        @rs.projects.transferStart(@.projectId, @.selected.id, @.comment)
            .then () =>
                @.loading = false
                @lightboxService.closeAll()

                title = @translate.instant("ADMIN.PROJECT_PROFILE.CHANGE_OWNER_SUCCESS_TITLE")
                desc = @translate.instant("ADMIN.PROJECT_PROFILE.CHANGE_OWNER_SUCCESS_DESC")

                @confirm.success(title, desc, {
                    type: "svg",
                    name: "icon-speak-up"
                })

ChangeOwnerLightboxController.$inject = [
        "tgResources",
        "lightboxService",
        "$tgConfirm",
        "$translate"
]

module.controller('ChangeOwnerLightbox', ChangeOwnerLightboxController)

ChangeOwnerLightboxDirective = (lightboxService, lightboxKeyboardNavigationService, $template, $compile) ->
    link = (scope, el) ->
        lightboxService.open(el)

    return {
        scope: true,
        controller: "ChangeOwnerLightbox",
        controllerAs: "vm",
        bindToController: {
            currentOwnerId: "=",
            projectId: "=",
            activeUsers: "="
        },
        templateUrl: "common/lightbox/lightbox-change-owner.html"
        link:link
    }


module.directive("tgLbChangeOwner", ["lightboxService", "lightboxKeyboardNavigationService", "$tgTemplate", "$compile", ChangeOwnerLightboxDirective])

TransferProjectStartSuccessDirective = (lightboxService) ->
    link = (scope, el) ->
        scope.close = () ->
            lightboxService.close(el)

        lightboxService.open(el)

    return {
        templateUrl: "common/lightbox/lightbox-transfer-project-start-success.html"
        link:link
    }


module.directive("tgLbTransferProjectStartSuccess", ["lightboxService", TransferProjectStartSuccessDirective])
