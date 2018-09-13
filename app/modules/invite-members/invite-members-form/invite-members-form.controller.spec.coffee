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
# File: invite-members/invite-members-form/invite-members-form.controller.spec.coffee
###

describe "InviteMembersFormController", ->
    inviteMembersFormCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockProjectService = () ->
        mocks.projectService = {
            project: sinon.stub()
            fetchProject: sinon.stub()
        }

        provide.value "tgProjectService", mocks.projectService

    _mockTgResources = () ->
        mocks.tgResources = {
            memberships: {
                bulkCreateMemberships: sinon.stub()
            }
        }

        provide.value "$tgResources", mocks.tgResources

    _mockLightboxService = () ->
        mocks.lightboxService = {
            closeAll: sinon.stub()
        }

        provide.value "lightboxService", mocks.lightboxService

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockRootScope = ->
        mocks.rootScope = {
            $broadcast: sinon.stub()
        }

        provide.value("$rootScope", mocks.rootScope)

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockProjectService()
            _mockTgResources()
            _mockLightboxService()
            _mockTgConfirm()
            _mockRootScope()
            return null

    beforeEach ->
        module "taigaAdmin"

        _mocks()

        inject ($controller) ->
            controller = $controller

        mocks.projectService.project = Immutable.fromJS([{
            'roles': 'role1'
        }])

    it "check limit memberships - no limit", () ->
        inviteMembersFormCtrl = controller "InviteMembersFormCtrl"

        inviteMembersFormCtrl.project = Immutable.fromJS({
            'max_memberships': null,
        })

        inviteMembersFormCtrl.defaultMaxInvites = 4

        inviteMembersFormCtrl._checkLimitMemberships()
        expect(inviteMembersFormCtrl.membersLimit).to.be.equal(4)
        expect(inviteMembersFormCtrl.showWarningMessage).to.be.false

    it "check limit memberships", () ->
        inviteMembersFormCtrl = controller "InviteMembersFormCtrl"

        inviteMembersFormCtrl.project = Immutable.fromJS({
            'max_memberships': 15,
            'total_memberships': 13
        })
        inviteMembersFormCtrl.defaultMaxInvites = 4

        inviteMembersFormCtrl._checkLimitMemberships()
        expect(inviteMembersFormCtrl.membersLimit).to.be.equal(2)
        expect(inviteMembersFormCtrl.showWarningMessage).to.be.true


    it "send invites", (done) ->
        inviteMembersFormCtrl = controller "InviteMembersFormCtrl"
        inviteMembersFormCtrl.project = Immutable.fromJS(
            {'id': 1}
        )
        inviteMembersFormCtrl.rolesValues = {'user1': 1}
        inviteMembersFormCtrl.inviteContactsMessage = 'Message'
        inviteMembersFormCtrl.loading = true

        mocks.tgResources.memberships.bulkCreateMemberships.withArgs(
            1,
            [{
                'role_id': 1
                'username': 'user1'
            }],
            'Message'
        ).promise().resolve()

        mocks.projectService.fetchProject.withArgs().promise().resolve()

        inviteMembersFormCtrl.sendInvites().then () ->
            expect(inviteMembersFormCtrl.loading).to.be.false
            expect(mocks.rootScope.$broadcast).to.have.been.calledWith("membersform:new:success")
            expect(mocks.tgConfirm.notify).to.have.been.calledWith("success")
            done()
