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
# File: invite-members/suggest-add-members/suggest-add-members.controller.spec.coffee
###

describe "SuggestAddMembersController", ->
    suggestAddMembersCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            return null

    beforeEach ->
        module "taigaAdmin"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "is email - wrong", () ->
        suggestAddMembersCtrl = controller "SuggestAddMembersCtrl"
        suggestAddMembersCtrl.contactQuery = 'lololo'

        result = suggestAddMembersCtrl.isEmail()
        expect(result).to.be.false

    it "is email - true", () ->
        suggestAddMembersCtrl = controller "SuggestAddMembersCtrl"
        suggestAddMembersCtrl.contactQuery = 'lololo@lolo.com'

        result = suggestAddMembersCtrl.isEmail()
        expect(result).to.be.true

    it "filter contacts", () ->
        suggestAddMembersCtrl = controller "SuggestAddMembersCtrl"
        suggestAddMembersCtrl.contacts = Immutable.fromJS([
            {
                full_name_display: 'Abel Sonofadan'
                username: 'abel'
            },
            {
                full_name_display: 'Cain Sonofadan'
                username: 'cain'
            }
        ])

        suggestAddMembersCtrl.contactQuery = 'Cain Sonofadan'

        suggestAddMembersCtrl.filterContacts()
        expect(suggestAddMembersCtrl.filteredContacts.size).to.be.equal(1)

    it "set invited", () ->
        suggestAddMembersCtrl = controller "SuggestAddMembersCtrl"

        contact = 'contact'

        suggestAddMembersCtrl.onInviteSuggested = sinon.stub()

        suggestAddMembersCtrl.setInvited(contact)
        expect(suggestAddMembersCtrl.onInviteSuggested).has.been.calledWith({'contact': contact})
