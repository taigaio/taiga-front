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
# File: related-userstory-row.controller.spec.coffee
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

        mocks.translate.instant.withArgs("EPIC.TITLE_LIGHTBOX_DELETE_RELATED_USERSTORY").returns("title")
        mocks.translate.instant.withArgs("EPIC.MSG_LIGHTBOX_DELETE_RELATED_USERSTORY", {subject: "Deleting"}).returns("message")

        mocks.tgConfirm.askOnDelete = sinon.stub()
        mocks.tgConfirm.askOnDelete.withArgs("title", "message").promise().resolve(askResponse)

        promise = mocks.tgResources.epics.deleteRelatedUserstory.withArgs(123, 124).promise().resolve(true)
        RelatedUserstoryRowCtrl.onDeleteRelatedUserstory().then () ->
            expect(mocks.tgResources.epics.deleteRelatedUserstory).have.been.calledWith(123, 124)
            expect(RelatedUserstoryRowCtrl.loadRelatedUserstories).have.been.calledOnce
            expect(askResponse.finish).have.been.calledOnce
            done()

    it "delete related userstory error", (done) ->
        RelatedUserstoryRowCtrl.epic = Immutable.fromJS({
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

        mocks.translate.instant.withArgs("EPIC.TITLE_LIGHTBOX_DELETE_RELATED_USERSTORY").returns("title")
        mocks.translate.instant.withArgs("EPIC.MSG_LIGHTBOX_DELETE_RELATED_USERSTORY", {subject: "Deleting"}).returns("message")
        mocks.translate.instant.withArgs("EPIC.ERROR_DELETE_RELATED_USERSTORY", {errorMessage: "message"}).returns("error message")

        mocks.tgConfirm.askOnDelete = sinon.stub()
        mocks.tgConfirm.askOnDelete.withArgs("title", "message").promise().resolve(askResponse)

        promise = mocks.tgResources.epics.deleteRelatedUserstory.withArgs(123, 124).promise().reject(new Error("error"))
        RelatedUserstoryRowCtrl.onDeleteRelatedUserstory().then () ->
            expect(mocks.tgResources.epics.deleteRelatedUserstory).have.been.calledWith(123, 124)
            expect(RelatedUserstoryRowCtrl.loadRelatedUserstories).to.not.have.been.called
            expect(askResponse.finish).have.been.calledWith(false)
            expect(mocks.tgConfirm.notify).have.been.calledWith("error", null, "error message")
            done()
