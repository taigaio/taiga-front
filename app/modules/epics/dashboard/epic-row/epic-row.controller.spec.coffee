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
# File: epic-row.controller.spec.coffee
###

describe "EpicRow", ->
    epicRowCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgResources = () ->
        mocks.tgResources = {
            epics: {
                patch: sinon.stub()
            },
            userstories: {
                listInEpic: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgResources()
            _mockTgConfirm()

            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.displayUserStories = false
        EpicRowCtrl.displayAssignedTo = false
        EpicRowCtrl.loadingStatus = false

    it "calculate progress bar in open US", () ->

        EpicRowCtrl = controller "EpicRowCtrl"

        EpicRowCtrl.epic = Immutable.fromJS({
            status_extra_info: {
                is_closed: false
            }
            user_stories_counts: {
                opened: 10,
                closed: 10
            }
        })

        EpicRowCtrl._calculateProgressBar()
        expect(EpicRowCtrl.opened).to.be.equal(10)
        expect(EpicRowCtrl.closed).to.be.equal(10)
        expect(EpicRowCtrl.total).to.be.equal(20)
        expect(EpicRowCtrl.percentage).to.be.equal("50%")

    it "calculate progress bar in zero US", () ->
        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.epic = Immutable.fromJS({
            status_extra_info: {
                is_closed: false
            }
            user_stories_counts: {
                opened: 0,
                closed: 0
            }
        })
        EpicRowCtrl._calculateProgressBar()
        expect(EpicRowCtrl.opened).to.be.equal(0)
        expect(EpicRowCtrl.closed).to.be.equal(0)
        expect(EpicRowCtrl.total).to.be.equal(0)
        expect(EpicRowCtrl.percentage).to.be.equal("0%")

    it "calculate progress bar in zero US", () ->
        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.epic = Immutable.fromJS({
            status_extra_info: {
                is_closed: true
            }
        })
        EpicRowCtrl._calculateProgressBar()
        expect(EpicRowCtrl.percentage).to.be.equal("100%")

    it "Update Epic Status Success", (done) ->
        EpicRowCtrl = controller "EpicRowCtrl"

        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1,
            version: 1
        })

        EpicRowCtrl.patch = {
            'status': 'new',
            'version': EpicRowCtrl.epic.get('version')
        }

        EpicRowCtrl.loadingStatus = true
        EpicRowCtrl.onUpdateEpic = sinon.stub()

        promise = mocks.tgResources.epics.patch.withArgs(EpicRowCtrl.epic.get('id'), EpicRowCtrl.patch).promise().resolve()

        status = "new"
        EpicRowCtrl.updateEpicStatus(status).then () ->
            expect(EpicRowCtrl.loadingStatus).to.be.false
            expect(EpicRowCtrl.displayStatusList).to.be.false
            expect(EpicRowCtrl.onUpdateEpic).to.be.called
            done()

    it "Update Epic Status Error", (done) ->
        EpicRowCtrl = controller "EpicRowCtrl"

        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1,
            version: 1
        })

        EpicRowCtrl.patch = {
            'status': 'new',
            'version': EpicRowCtrl.epic.get('version')
        }

        EpicRowCtrl.loadingStatus = true
        EpicRowCtrl.onUpdateEpic = sinon.stub()

        promise = mocks.tgResources.epics.patch.withArgs(EpicRowCtrl.epic.get('id'), EpicRowCtrl.patch).promise().reject(new Error('error'))

        status = "new"
        EpicRowCtrl.updateEpicStatus(status).then () ->
            expect(mocks.tgConfirm.notify).have.been.calledWith('error')
            done()

    it "display User Stories", (done) ->
        EpicRowCtrl = controller "EpicRowCtrl"

        EpicRowCtrl.displayUserStories = false
        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1
        })
        data = true

        promise = mocks.tgResources.userstories.listInEpic.withArgs(EpicRowCtrl.epic.get('id')).promise().resolve(data)

        EpicRowCtrl.requestUserStories(EpicRowCtrl.epic).then () ->
            expect(EpicRowCtrl.displayUserStories).to.be.true
            expect(EpicRowCtrl.epicStories).is.equal(data)
            done()

    it "display User Stories error", (done) ->
        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.displayUserStories = false

        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1
        })

        promise = mocks.tgResources.userstories.listInEpic.withArgs(EpicRowCtrl.epic.get('id')).promise().reject(new Error('error'))

        EpicRowCtrl.requestUserStories(EpicRowCtrl.epic).then () ->
            expect(mocks.tgConfirm.notify).have.been.calledWith('error')
            done()

    it "DO NOT display User Stories", () ->
        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.displayUserStories = true

        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1
        })
        EpicRowCtrl.requestUserStories(EpicRowCtrl.epic)
        expect(EpicRowCtrl.displayUserStories).to.be.false

    it "On remove assigned", () ->
        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1,
            version: 1
        })
        EpicRowCtrl.patch = {
            'assigned_to': null,
            'version': EpicRowCtrl.epic.get('version')
        }
        EpicRowCtrl.onUpdateEpic = sinon.stub()

        promise = mocks.tgResources.epics.patch.withArgs(EpicRowCtrl.epic.get('id'), EpicRowCtrl.patch).promise().resolve()

        EpicRowCtrl.onRemoveAssigned().then () ->
            expect(EpicRowCtrl.onUpdateEpic).to.have.been.called

    it "On assign to", (done) ->
        EpicRowCtrl = controller "EpicRowCtrl"
        EpicRowCtrl.epic = Immutable.fromJS({
            id: 1,
            version: 1
        })
        id = EpicRowCtrl.epic.get('id')
        version = EpicRowCtrl.epic.get('version')
        member = {
            id: 1
        }
        EpicRowCtrl.patch = {
            assigned_to: member.id
            version: EpicRowCtrl.epic.get('version')
        }

        EpicRowCtrl.onUpdateEpic = sinon.stub()

        promise = mocks.tgResources.epics.patch.withArgs(id, EpicRowCtrl.patch).promise().resolve(member)
        EpicRowCtrl.onAssignTo(member).then () ->
            expect(EpicRowCtrl.onUpdateEpic).to.have.been.called
            expect(mocks.tgConfirm.notify).have.been.calledWith('success')
            done()
