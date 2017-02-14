###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: invite-members.controller.spec.coffee
###

describe "InviteMembersController", ->
    provide = null
    controller = null

    beforeEach ->
        module "taigaProjects"

        inject ($controller) ->
            controller = $controller

    it "add member to invitation", () ->
        ctrl = controller "InviteMembersCtrl"
        ctrl.displayUserWarning = true
        ctrl.onSetInvitedMembers = sinon.stub()

        ctrl.invitedMembers = Immutable.fromJS([
            {
                id: 1
            },
            {
                id: 2
            }
        ])

        project = Immutable.fromJS({
            name: "projectName"
            members: []
        })

        member = Immutable.fromJS({
            id: 3
        })

        memberlist = [1, 2]

        ctrl.toggleInviteMember(member)
        expect(ctrl.invitedMembers.size).to.be.equal(3)
        expect(ctrl.displayUserWarning).to.be.false
        expect(ctrl.onSetInvitedMembers).to.be.calledWith({members: ctrl.invitedMembers})

    it "remove member from invitation", () ->
        ctrl = controller "InviteMembersCtrl"
        ctrl.displayUserWarning = true
        ctrl.onSetInvitedMembers = sinon.stub()

        ctrl.invitedMembers = Immutable.fromJS([
            {
                id: 1
            },
            {
                id: 2
            }
        ])

        project = Immutable.fromJS({
            name: "projectName"
            members: []
        })

        member = Immutable.fromJS({
            id: 1
        })

        memberlist = [1, 2]

        ctrl.toggleInviteMember(member)
        expect(ctrl.invitedMembers.size).to.be.equal(1)
        expect(ctrl.displayUserWarning).to.be.false
        expect(ctrl.onSetInvitedMembers).to.be.calledWith({members: ctrl.invitedMembers})

    it "remove all members from invitation", () ->
        ctrl = controller "InviteMembersCtrl"
        ctrl.displayUserWarning = true
        ctrl.onSetInvitedMembers = sinon.stub()

        ctrl.invitedMembers = Immutable.fromJS([
            {
                id: 1
            }
        ])

        project = Immutable.fromJS({
            name: "projectName"
            members: []
        })

        member = Immutable.fromJS({
            id: 1
        })

        memberlist = [1]

        ctrl.toggleInviteMember(member)
        expect(ctrl.invitedMembers.size).to.be.equal(0)
        expect(ctrl.displayUserWarning).to.be.true
        expect(ctrl.onSetInvitedMembers).to.be.calledWith({members: ctrl.invitedMembers})
