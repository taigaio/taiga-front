###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
## Create Members Lightbox Directive
#############################################################################

class LightboxAddMembersController
    @.$inject = [
        "$scope",
        "lightboxService",
        "tgLoader",
        "$tgConfirm",
        "$tgResources",
        "$rootScope",
    ]

    constructor: (@scope, @lightboxService, @tgLoader, @confirm, @rs, @rootScope) ->
        @._defaultMaxInvites = 4
        @._defaultRole = @.project.roles[0].id
        @.form = null
        @.submitInvites = false
        @.canAddUsers = true
        @.memberInvites = []

        if @.project.max_memberships == null
            @.membersLimit = @._defaultMaxInvites
        else
            pendingMembersCount = Math.max(@.project.max_memberships - @.project.total_memberships, 0)
            @.membersLimit = Math.min(pendingMembersCount, @._defaultMaxInvites)

        @.addSingleMember()

    addSingleMember: () ->
        @.memberInvites.push({email:'', role_id: @._defaultRole})

        if @.memberInvites.length >= @.membersLimit
            @.canAddUsers = false
        @.showWarningMessage = (!@.canAddUsers &&
                            @.project.total_memberships + @.memberInvites.length == @.project.max_memberships)

    removeSingleMember: (index) ->
        @.memberInvites.splice(index, 1)

        @.canAddUsers = true
        @.showWarningMessage = @.membersLimit == 1

    submit: () ->
        # Need to reset the form constrains
        @.form.initializeFields()
        @.form.reset()
        return if not @.form.validate()

        @.submitInvites = true
        promise = @rs.memberships.bulkCreateMemberships(
            @.project.id,
            @.memberInvites,
            @.invitationText
        )
        promise.then(
            @._onSuccessInvite.bind(this),
            @._onErrorInvite.bind(this)
        )

    _onSuccessInvite: () ->
        @.submitInvites = false
        @rootScope.$broadcast("membersform:new:success")
        @lightboxService.closeAll()
        @confirm.notify("success")

    _onErrorInvite: (response) ->
        @.submitInvites = false
        @.form.setErrors(response.data)
        if response.data._error_message
            @confirm.notify("error", response.data._error_message)

module.controller("LbAddMembersController", LightboxAddMembersController)



LightboxAddMembersDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        lightboxService.open(el)
        ctrl.form = el.find("form").checksley()

    return {
        scope: {},
        bindToController: {
            project: '=',
        },
        controller: 'LbAddMembersController',
        controllerAs: 'vm',
        templateUrl: 'admin/lightbox-add-members.html',
        link: link
    }

module.directive("tgLbAddMembers", ["lightboxService", LightboxAddMembersDirective])


#############################################################################
## Warning message directive
#############################################################################

LightboxAddMembersWarningMessageDirective = () ->
    return {
          templateUrl: "admin/lightbox-add-members-no-more=memberships-warning-message.html"
          scope: {
              project: "="
          }
    }

module.directive("tgLightboxAddMembersWarningMessage", [LightboxAddMembersWarningMessageDirective])
