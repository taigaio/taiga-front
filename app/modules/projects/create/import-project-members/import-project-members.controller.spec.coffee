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
# File: projects/create/import-project-members/import-project-members.controller.spec.coffee
###

describe "ImportProjectMembersCtrl", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockCurrentUserService = ->
        mocks.currentUserService = {
            getUser: sinon.stub().returns(Immutable.fromJS({
                id: 1
            })),
            canAddMembersPrivateProject: sinon.stub(),
            canAddMembersPublicProject: sinon.stub()
        }

        $provide.value("tgCurrentUserService", mocks.currentUserService)

    _mockUserService = ->
        mocks.userService = {
            getContacts: sinon.stub()
        }

        $provide.value("tgUserService", mocks.userService)

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockCurrentUserService()
            _mockUserService()

            return null

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "fetch user info", (done) ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.refreshSelectableUsers = sinon.spy()

        mocks.userService.getContacts.withArgs(1).promise().resolve('contacts')

        ctrl.fetchUser().then () ->
            expect(ctrl.userContacts).to.be.equal('contacts')
            expect(ctrl.refreshSelectableUsers).have.been.called
            done()

    it "search user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        user = {
            id: 1,
            name: "username"
        }

        ctrl.searchUser(user)

        expect(ctrl.selectImportUserLightbox).to.be.true
        expect(ctrl.searchingUser).to.be.equal(user)

    it "prepare submit users, warning if needed", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        user = {
            id: 1,
            name: "username"
        }

        ctrl.selectedUsers = Immutable.fromJS([
            {id: 1},
            {id: 2}
        ])

        ctrl.members = Immutable.fromJS([
            {id: 1}
        ])

        ctrl.beforeSubmitUsers()

        expect(ctrl.warningImportUsers).to.be.true

    it "prepare submit users, submit", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        user = {
            id: 1,
            name: "username"
        }

        ctrl.selectedUsers = Immutable.fromJS([
            {id: 1}
        ])

        ctrl.members = Immutable.fromJS([
            {id: 1}
        ])


        ctrl.submit = sinon.spy()
        ctrl.beforeSubmitUsers()

        expect(ctrl.warningImportUsers).to.be.false
        expect(ctrl.submit).have.been.called

    it "confirm user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.discardSuggestedUser = sinon.spy()
        ctrl.refreshSelectableUsers = sinon.spy()

        ctrl.confirmUser('user', 'taiga-user')

        expect(ctrl.selectedUsers.size).to.be.equal(1)

        expect(ctrl.selectedUsers.get(0).get('user')).to.be.equal('user')
        expect(ctrl.selectedUsers.get(0).get('taigaUser')).to.be.equal('taiga-user')
        expect(ctrl.discardSuggestedUser).have.been.called
        expect(ctrl.refreshSelectableUsers).have.been.called

    it "discard suggested user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.discardSuggestedUser(Immutable.fromJS({
            id: 3
        }))

        expect(ctrl.cancelledUsers.get(0)).to.be.equal(3)

    it "clean member selection", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.refreshSelectableUsers = sinon.spy()

        ctrl.selectedUsers = Immutable.fromJS([
            {
                user: {
                    id: 1
                }
            },
            {
                user: {
                    id: 2
                }
            }
        ])

        ctrl.unselectUser(Immutable.fromJS({
            id: 2
        }))

        expect(ctrl.selectedUsers.size).to.be.equal(1)
        expect(ctrl.refreshSelectableUsers).have.been.called


    it "get a selected member", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        member = Immutable.fromJS({
            id: 3
        })

        ctrl.selectedUsers = ctrl.selectedUsers.push(Immutable.fromJS({
            user: {
                id: 3
            }
        }))

        user = ctrl.getSelectedMember(member)

        expect(user.getIn(['user', 'id'])).to.be.equal(3)

    it "submit", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.selectedUsers = ctrl.selectedUsers.push(Immutable.fromJS({
            user: {
                id: 3
            },
            taigaUser: {
                id: 2
            }
        }))

        ctrl.selectedUsers = ctrl.selectedUsers.push(Immutable.fromJS({
            user: {
                id: 3
            },
            taigaUser: "xx@yy.com"
        }))


        ctrl.onSubmit = sinon.stub()

        ctrl.submit()

        user = Immutable.Map()
        user = user.set(3, 2)

        expect(ctrl.onSubmit).have.been.called
        expect(ctrl.warningImportUsers).to.be.false

    it "show suggested match", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.isMemberSelected = sinon.stub().returns(false)
        ctrl.cancelledUsers = [
            3
        ]

        member = Immutable.fromJS({
            id: 1,
            user: {
                id: 10
            }
        })

        expect(ctrl.showSuggestedMatch(member)).to.be.true

    it "doesn't show suggested match", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.isMemberSelected = sinon.stub().returns(false)
        ctrl.cancelledUsers = [
            3
        ]

        member = Immutable.fromJS({
            id: 3,
            user: {
                id: 10
            }
        })

        expect(ctrl.showSuggestedMatch(member)).to.be.false

    it "check users limit", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.members = Immutable.fromJS([
            1, 2, 3
        ])

        mocks.currentUserService.canAddMembersPrivateProject.withArgs(4).returns('xx')
        mocks.currentUserService.canAddMembersPublicProject.withArgs(4).returns('yy')

        ctrl.checkUsersLimit()

        expect(ctrl.limitMembersPrivateProject).to.be.equal('xx')
        expect(ctrl.limitMembersPublicProject).to.be.equal('yy')


     it "get distict select taiga users excluding the current user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")
        ctrl.selectedUsers = Immutable.fromJS([
            {
                taigaUser: {
                    id: 1
                }
            },
            {
                taigaUser: {
                    id: 1
                }
            },
            {
                taigaUser: {
                    id: 3
                }
            },
            {
                taigaUser: {
                    id: 5
                }
            }
        ])

        ctrl.currentUser = Immutable.fromJS({
            id: 5
        })

        users = ctrl.getDistinctSelectedTaigaUsers()

        expect(users.size).to.be.equal(2)

     it "refresh selectable users array with all users available", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.isImportMoreUsersDisabled = sinon.stub().returns(false)
        ctrl.displayEmailSelector = false

        ctrl.userContacts = Immutable.fromJS([1])
        ctrl.currentUser = 2

        ctrl.refreshSelectableUsers()

        expect(ctrl.selectableUsers.toJS()).to.be.eql([1, 2])
        expect(ctrl.displayEmailSelector).to.be.true


     it "refresh selectable users array with the selected ones", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.getDistinctSelectedTaigaUsers = sinon.stub().returns(Immutable.fromJS([
            {taigaUser: 1}
        ]))
        ctrl.displayEmailSelector = false

        ctrl.isImportMoreUsersDisabled = sinon.stub().returns(true)

        ctrl.userContacts = Immutable.fromJS([1])
        ctrl.currentUser = 2

        ctrl.refreshSelectableUsers()

        expect(ctrl.selectableUsers.toJS()).to.be.eql([1, 2])
        expect(ctrl.displayEmailSelector).to.be.false

    it "import more user disable in private project", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.project = Immutable.fromJS({
            is_private: true
        })

        ctrl.getDistinctSelectedTaigaUsers = sinon.stub().returns(Immutable.fromJS([1,2,3]))

        mocks.currentUserService.canAddMembersPrivateProject.withArgs(5).returns({valid: true})

        expect(ctrl.isImportMoreUsersDisabled()).to.be.false

    it "import more user disable in public project", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.project = Immutable.fromJS({
            is_private: false
        })

        ctrl.getDistinctSelectedTaigaUsers = sinon.stub().returns(Immutable.fromJS([1,2,3]))

        mocks.currentUserService.canAddMembersPublicProject.withArgs(5).returns({valid: true})

        expect(ctrl.isImportMoreUsersDisabled()).to.be.false
