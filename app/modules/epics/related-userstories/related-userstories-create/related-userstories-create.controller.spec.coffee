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
# File: epics/related-userstories/related-userstories-create/related-userstories-create.controller.spec.coffee
###

describe "RelatedUserstoriesCreate", ->
    RelatedUserstoriesCreateCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgCurrentUserService = () ->
        mocks.tgCurrentUserService = {
            projects: {
                get: sinon.stub()
            }
        }

        provide.value "tgCurrentUserService", mocks.tgCurrentUserService

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            askOnDelete: sinon.stub()
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm


    _mockTgResources = () ->
        mocks.tgResources = {
            userstories: {
                listInAllProjects: sinon.stub()
            }
            epics: {
                deleteRelatedUserstory: sinon.stub()
                addRelatedUserstory: sinon.stub()
                bulkCreateRelatedUserStories: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgAnalytics = () ->
        mocks.tgAnalytics = {
            trackEvent: sinon.stub()
        }

        provide.value "$tgAnalytics", mocks.tgAnalytics

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgCurrentUserService()
            _mockTgConfirm()
            _mockTgResources()
            _mockTgAnalytics()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

        RelatedUserstoriesCreateCtrl = controller "RelatedUserstoriesCreateCtrl"

    it "select project", (done) ->
        # This test tries to reproduce a project containing userstories 11 and 12 where 11
        # is yet related to the epic
        RelatedUserstoriesCreateCtrl.epicUserstories = Immutable.fromJS([
            {
                id: 11
            }
        ])

        userstories = Immutable.fromJS([
            {
                id: 11
            },
            {

                id: 12
            }
        ])
        filteredUserstories = Immutable.fromJS([
            {

                id: 12
            }
        ])

        promise = mocks.tgResources.userstories.listInAllProjects.withArgs({project:1, q:""}).promise().resolve(userstories)
        RelatedUserstoriesCreateCtrl.filterUss(1, "").then () ->
            expect(RelatedUserstoriesCreateCtrl.projectUserstories.toJS()).to.eql(filteredUserstories.toJS())
            done()

    it "save related user story success", (done) ->
        RelatedUserstoriesCreateCtrl.validateExistingUserstoryForm = sinon.stub()
        RelatedUserstoriesCreateCtrl.validateExistingUserstoryForm.returns(true)
        onSavedRelatedUserstoryCallback = sinon.stub()
        onSavedRelatedUserstoryCallback.returns(true)
        RelatedUserstoriesCreateCtrl.loadRelatedUserstories = sinon.stub()
        RelatedUserstoriesCreateCtrl.epic = Immutable.fromJS({
            id: 1
        })
        promise = mocks.tgResources.epics.addRelatedUserstory.withArgs(1, 11).promise().resolve(true)
        RelatedUserstoriesCreateCtrl.saveRelatedUserStory(11, onSavedRelatedUserstoryCallback).then () ->
            expect(RelatedUserstoriesCreateCtrl.validateExistingUserstoryForm).have.been.calledOnce
            expect(onSavedRelatedUserstoryCallback).have.been.calledOnce
            expect(mocks.tgResources.epics.addRelatedUserstory).have.been.calledWith(1, 11)
            expect(mocks.tgAnalytics.trackEvent).have.been.calledWith("epic related user story", "create", "create related user story on epic", 1)
            expect(RelatedUserstoriesCreateCtrl.loadRelatedUserstories).have.been.calledOnce
            done()

    it "save related user story error", (done) ->
        RelatedUserstoriesCreateCtrl.validateExistingUserstoryForm = sinon.stub()
        RelatedUserstoriesCreateCtrl.validateExistingUserstoryForm.returns(true)
        onSavedRelatedUserstoryCallback = sinon.stub()
        RelatedUserstoriesCreateCtrl.setExistingUserstoryFormErrors = sinon.stub()
        RelatedUserstoriesCreateCtrl.setExistingUserstoryFormErrors.returns({})
        RelatedUserstoriesCreateCtrl.epic = Immutable.fromJS({
            id: 1
        })
        promise = mocks.tgResources.epics.addRelatedUserstory.withArgs(1, 11).promise().reject(new Error("error"))
        RelatedUserstoriesCreateCtrl.saveRelatedUserStory(11, onSavedRelatedUserstoryCallback).then () ->
            expect(RelatedUserstoriesCreateCtrl.validateExistingUserstoryForm).have.been.calledOnce
            expect(onSavedRelatedUserstoryCallback).to.not.have.been.called
            expect(mocks.tgResources.epics.addRelatedUserstory).have.been.calledWith(1, 11)
            expect(mocks.tgConfirm.notify).have.been.calledWith("error")
            expect(RelatedUserstoriesCreateCtrl.setExistingUserstoryFormErrors).have.been.calledOnce
            done()

    it "bulk create related user stories success", (done) ->
        RelatedUserstoriesCreateCtrl.validateNewUserstoryForm = sinon.stub()
        RelatedUserstoriesCreateCtrl.validateNewUserstoryForm.returns(true)
        onCreatedRelatedUserstoryCallback = sinon.stub()
        onCreatedRelatedUserstoryCallback.returns(true)
        RelatedUserstoriesCreateCtrl.loadRelatedUserstories = sinon.stub()
        RelatedUserstoriesCreateCtrl.epic = Immutable.fromJS({
            id: 1
        })
        promise = mocks.tgResources.epics.bulkCreateRelatedUserStories.withArgs(1, 22, 'a\nb').promise().resolve(true)
        RelatedUserstoriesCreateCtrl.bulkCreateRelatedUserStories(22, 'a\nb', onCreatedRelatedUserstoryCallback).then () ->
            expect(RelatedUserstoriesCreateCtrl.validateNewUserstoryForm).have.been.calledOnce
            expect(onCreatedRelatedUserstoryCallback).have.been.calledOnce
            expect(mocks.tgResources.epics.bulkCreateRelatedUserStories).have.been.calledWith(1, 22, 'a\nb')
            expect(mocks.tgAnalytics.trackEvent).have.been.calledWith("epic related user story", "create", "create related user story on epic", 1)
            expect(RelatedUserstoriesCreateCtrl.loadRelatedUserstories).have.been.calledOnce
            done()

    it "bulk create related user stories error", (done) ->
        RelatedUserstoriesCreateCtrl.validateNewUserstoryForm = sinon.stub()
        RelatedUserstoriesCreateCtrl.validateNewUserstoryForm.returns(true)
        onCreatedRelatedUserstoryCallback = sinon.stub()
        RelatedUserstoriesCreateCtrl.setNewUserstoryFormErrors = sinon.stub()
        RelatedUserstoriesCreateCtrl.setNewUserstoryFormErrors.returns({})
        RelatedUserstoriesCreateCtrl.epic = Immutable.fromJS({
            id: 1
        })
        promise = mocks.tgResources.epics.bulkCreateRelatedUserStories.withArgs(1, 22, 'a\nb').promise().reject(new Error("error"))
        RelatedUserstoriesCreateCtrl.bulkCreateRelatedUserStories(22, 'a\nb', onCreatedRelatedUserstoryCallback).then () ->
            expect(RelatedUserstoriesCreateCtrl.validateNewUserstoryForm).have.been.calledOnce
            expect(onCreatedRelatedUserstoryCallback).to.not.have.been.called
            expect(mocks.tgResources.epics.bulkCreateRelatedUserStories).have.been.calledWith(1, 22, 'a\nb')
            expect(mocks.tgConfirm.notify).have.been.calledWith("error")
            expect(RelatedUserstoriesCreateCtrl.setNewUserstoryFormErrors).have.been.calledOnce
            done()
