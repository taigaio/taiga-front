###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
