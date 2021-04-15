###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
