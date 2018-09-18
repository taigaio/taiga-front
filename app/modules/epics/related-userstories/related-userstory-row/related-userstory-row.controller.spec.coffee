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
# File: epics/related-userstories/related-userstory-row/related-userstory-row.controller.spec.coffee
###

describe "RelatedUserstoryRow", ->
    RelatedUserstoryRowCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            askOnDelete: sinon.stub()
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgAvatarService = () ->
        mocks.tgAvatarService = {
            getAvatar: sinon.stub()
        }

        provide.value "tgAvatarService", mocks.tgAvatarService

    _mockTranslate = () ->
        mocks.translate = {
            instant: sinon.stub()
        }

        provide.value "$translate", mocks.translate

    _mockTgResources = () ->
        mocks.tgResources = {
            epics: {
                deleteRelatedUserstory: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgAvatarService()
            _mockTranslate()
            _mockTgResources()

            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

        RelatedUserstoryRowCtrl = controller "RelatedUserstoryRowCtrl"

    it "set avatar data", (done) ->
        RelatedUserstoryRowCtrl.userstory = Immutable.fromJS({
            assigned_to_extra_info: {
                id: 3
            }
        })
        member = RelatedUserstoryRowCtrl.userstory.get("assigned_to_extra_info")
        avatar = {
            url: "http://taiga.io"
            bg: "#AAAAAA"
        }
        mocks.tgAvatarService.getAvatar.withArgs(member).returns(avatar)
        RelatedUserstoryRowCtrl.setAvatarData()
        expect(mocks.tgAvatarService.getAvatar).have.been.calledWith(member)
        expect(RelatedUserstoryRowCtrl.avatar).is.equal(avatar)
        done()

    it "get assigned to full name display for existing user", (done) ->
        RelatedUserstoryRowCtrl.userstory = Immutable.fromJS({
            assigned_to: 1
            assigned_to_extra_info: {
              full_name_display: "Beta tester"
            }
        })

        expect(RelatedUserstoryRowCtrl.getAssignedToFullNameDisplay()).is.equal("Beta tester")
        done()

    it "get assigned to full name display for unassigned user story", (done) ->
        RelatedUserstoryRowCtrl.userstory = Immutable.fromJS({
            assigned_to: null
        })
        mocks.translate.instant.withArgs("COMMON.ASSIGNED_TO.NOT_ASSIGNED").returns("Unassigned")
        expect(RelatedUserstoryRowCtrl.getAssignedToFullNameDisplay()).is.equal("Unassigned")
        done()

    it "delete related userstory success", (done) ->
        RelatedUserstoryRowCtrl.epic = Immutable.fromJS({
            subject: "SampleEpic"
            id: 123
        })
        RelatedUserstoryRowCtrl.userstory = Immutable.fromJS({
            subject: "Deleting"
            id: 124
        })

        RelatedUserstoryRowCtrl.loadRelatedUserstories = sinon.stub()

        askResponse = {
            finish: sinon.spy()
        }

        mocks.translate.instant.withArgs("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.TITLE").returns("title")
        mocks.translate.instant.withArgs("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.MESSAGE", {epicSubject: "SampleEpic"}).returns("message")

        mocks.tgConfirm.ask = sinon.stub()
        mocks.tgConfirm.ask.withArgs("title").promise().resolve(askResponse)

        promise = mocks.tgResources.epics.deleteRelatedUserstory.withArgs(123, 124).promise().resolve(true)
        RelatedUserstoryRowCtrl.onDeleteRelatedUserstory().then () ->
            expect(RelatedUserstoryRowCtrl.loadRelatedUserstories).have.been.calledOnce
            expect(askResponse.finish).have.been.calledOnce
            done()

    it "delete related userstory error", (done) ->
        RelatedUserstoryRowCtrl.epic = Immutable.fromJS({
            epicSubject: "SampleEpic"
            id: 123
        })
        RelatedUserstoryRowCtrl.userstory = Immutable.fromJS({
            subject: "Deleting"
            id: 124
        })

        RelatedUserstoryRowCtrl.loadRelatedUserstories = sinon.stub()

        askResponse = {
            finish: sinon.spy()
        }

        mocks.translate.instant.withArgs("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.TITLE").returns("title")
        mocks.translate.instant.withArgs("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.MESSAGE", {epicSubject: "SampleEpic"}).returns("message")
        mocks.translate.instant.withArgs("EPIC.ERROR_UNLINK_RELATED_USERSTORY").returns("error message")

        mocks.tgConfirm.ask = sinon.stub()
        mocks.tgConfirm.ask.withArgs("title").promise().resolve(askResponse)

        promise = mocks.tgResources.epics.deleteRelatedUserstory.withArgs(123, 124).promise().reject(new Error("error"))
        RelatedUserstoryRowCtrl.onDeleteRelatedUserstory().then () ->
            expect(RelatedUserstoryRowCtrl.loadRelatedUserstories).to.not.have.been.called
            expect(askResponse.finish).have.been.calledWith(false)
            expect(mocks.tgConfirm.notify).have.been.calledWith("error", null, "error message")
            done()
