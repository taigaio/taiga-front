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
# File: invite-members/lightbox-add-members.controller.spec.coffee
###

describe "AddMembersController", ->
    addMembersCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockUserService = () ->
        mocks.userService = {
            getContacts: sinon.stub()
        }

        provide.value "tgUserService", mocks.userService

    _mockCurrentUser = () ->
        mocks.currentUser = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUser

    _mockProjectService = () ->
        mocks.projectService = {
            project: sinon.stub()
        }

        provide.value "tgProjectService", mocks.projectService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockCurrentUser()
            _mockUserService()
            _mockProjectService()
            return null

    beforeEach ->
        module "taigaAdmin"

        _mocks()

        inject ($controller) ->
            controller = $controller


    it "get user contacts", (done) ->

        userId = 1
        excludeProjectId = 1

        mocks.currentUser.getUser.returns(Immutable.fromJS({
            id: userId
        }))
        mocks.projectService.project = Immutable.fromJS({
            id: excludeProjectId
        })

        contacts = Immutable.fromJS({
            username: "username",
            full_name_display: "full-name-display",
            bio: "bio"
        })

        mocks.userService.getContacts.withArgs(userId, excludeProjectId).promise().resolve(contacts)

        addMembersCtrl = controller "AddMembersCtrl"

        addMembersCtrl._getContacts().then () ->
            expect(addMembersCtrl.contacts).to.be.equal(contacts)
            done()

    it "filterContacts", () ->

        addMembersCtrl = controller "AddMembersCtrl"
        addMembersCtrl.contacts = Immutable.fromJS([
            {id: 1}
            {id: 2}
        ])
        invited = Immutable.fromJS({id: 1})

        addMembersCtrl._filterContacts(invited)

        expect(addMembersCtrl.contacts.size).to.be.equal(1)

    it "invite suggested", () ->
        addMembersCtrl = controller "AddMembersCtrl"
        addMembersCtrl.contactsToInvite = Immutable.List()
        addMembersCtrl.displayContactList = false

        contact = Immutable.fromJS({id: 1})

        addMembersCtrl._filterContacts = sinon.stub()

        addMembersCtrl.inviteSuggested(contact)
        expect(addMembersCtrl.contactsToInvite.size).to.be.equal(1)
        expect(addMembersCtrl._filterContacts).to.be.calledWith(contact)
        expect(addMembersCtrl.displayContactList).to.be.true

    it "remove contact", () ->
        addMembersCtrl = controller "AddMembersCtrl"
        addMembersCtrl.contactsToInvite = Immutable.fromJS([
            {id: 1}
            {id: 2}
        ])
        invited = {id: 1}
        addMembersCtrl.contacts = Immutable.fromJS([])

        addMembersCtrl.testEmptyContacts = sinon.stub()

        addMembersCtrl.removeContact(invited)
        expect(addMembersCtrl.contactsToInvite.size).to.be.equal(1)
        expect(addMembersCtrl.contacts.size).to.be.equal(1)
        expect(addMembersCtrl.testEmptyContacts).to.be.called

    it "invite email", () ->
        addMembersCtrl = controller "AddMembersCtrl"
        email = 'email@example.com'
        emailData = Immutable.Map({'email': email})
        addMembersCtrl.displayContactList = false

        addMembersCtrl.emailsToInvite = Immutable.fromJS([])

        addMembersCtrl.inviteEmail(email)
        expect(emailData.get('email')).to.be.equal(email)
        expect(addMembersCtrl.emailsToInvite.size).to.be.equal(1)
        expect(addMembersCtrl.displayContactList).to.be.true

    it "remove email", () ->
        addMembersCtrl = controller "AddMembersCtrl"
        invited = {email: 'email@example.com'}
        addMembersCtrl.emailsToInvite = Immutable.fromJS([
            {'email': 'email@example.com'}
            {'email': 'email@example2.com'}
        ])

        addMembersCtrl.testEmptyContacts = sinon.stub()

        addMembersCtrl.removeEmail(invited)
        expect(addMembersCtrl.emailsToInvite.size).to.be.equal(1)
        expect(addMembersCtrl.testEmptyContacts).to.be.called

    it "test empty contacts - not empty", () ->
        addMembersCtrl = controller "AddMembersCtrl"
        addMembersCtrl.displayContactList = true
        addMembersCtrl.emailsToInvite = Immutable.fromJS([
            {'email': 'email@example.com'}
            {'email': 'email@example2.com'}
        ])
        addMembersCtrl.contactsToInvite = Immutable.fromJS([
            {'id': 1}
            {'id': 1}
        ])
        addMembersCtrl.testEmptyContacts()
        expect(addMembersCtrl.displayContactList).to.be.true

    it "test empty contacts - empty", () ->
        addMembersCtrl = controller "AddMembersCtrl"
        addMembersCtrl.displayContactList = true
        addMembersCtrl.emailsToInvite = Immutable.fromJS([])
        addMembersCtrl.contactsToInvite = Immutable.fromJS([])
        addMembersCtrl.testEmptyContacts()
        expect(addMembersCtrl.displayContactList).to.be.false
