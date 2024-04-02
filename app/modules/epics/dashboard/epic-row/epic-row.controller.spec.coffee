###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "EpicRow", ->
    epicRowCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            project: {
                toJS: sinon.stub()
            }
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgEpicsService = () ->
        mocks.tgEpicsService = {
            listRelatedUserStories: sinon.stub()
            updateEpicStatus: sinon.stub()
            updateEpicAssignedTo: sinon.stub()
        }
        provide.value "tgEpicsService", mocks.tgEpicsService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgConfirm()
            _mockTgProjectService()
            _mockTgEpicsService()
            return null

    beforeEach ->
        module "taigaEpics"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "calculate progress bar in open US", () ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                status_extra_info: {
                    is_closed: false
                }
                user_stories_counts: {
                    total: 10,
                    progress: 5
                }
            })
        }

        expect(ctrl.percentage).to.be.equal("50%")

    it "calculate progress bar in zero US", () ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                status_extra_info: {
                    is_closed: false
                }
                user_stories_counts: {
                    total: 10,
                    progress: 0
                }
            })
        }
        expect(ctrl.percentage).to.be.equal("0%")

    it "calculate progress bar in zero US", () ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                status_extra_info: {
                    is_closed: true
                }
            })
        }
        expect(ctrl.percentage).to.be.equal("100%")

    it "Update Epic Status Success", (done) ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                id: 1
                version: 1
            })
        }

        statusId = 1

        promise = mocks.tgEpicsService.updateEpicStatus
            .withArgs(ctrl.epic, statusId)
            .promise()
            .resolve()

        ctrl.loadingStatus = true
        ctrl.displayStatusList = true

        ctrl.updateStatus(statusId).then () ->
            expect(ctrl.loadingStatus).to.be.false
            expect(ctrl.displayStatusList).to.be.false
            done()

    it "Update Epic Status Error", (done) ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                id: 1
                version: 1
            })
        }

        statusId = 1

        promise = mocks.tgEpicsService.updateEpicStatus
            .withArgs(ctrl.epic, statusId)
            .promise()
            .reject(new Error('error'))

        ctrl.updateStatus(statusId).then () ->
            expect(ctrl.loadingStatus).to.be.false
            expect(ctrl.displayStatusList).to.be.false
            expect(mocks.tgConfirm.notify).have.been.calledWith('error')
            done()

    it "display User Stories", (done) ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                id: 1
            })
        }

        ctrl.displayUserStories = false

        data = Immutable.List()

        promise = mocks.tgEpicsService.listRelatedUserStories
            .withArgs(ctrl.epic)
            .promise()
            .resolve(data)

        ctrl.toggleUserStoryList().then () ->
            expect(ctrl.displayUserStories).to.be.true
            expect(ctrl.epicStories).is.equal(data)
            done()

    it "display User Stories error", (done) ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                id: 1
            })
        }

        ctrl.displayUserStories = false

        promise = mocks.tgEpicsService.listRelatedUserStories
            .withArgs(ctrl.epic)
            .promise()
            .reject(new Error('error'))

        ctrl.toggleUserStoryList().then () ->
            expect(ctrl.displayUserStories).to.be.false
            expect(mocks.tgConfirm.notify).have.been.calledWith('error')
            done()

    it "display User Stories error", ->
        ctrl = controller "EpicRowCtrl", null, {
            epic: Immutable.fromJS({
                id: 1
            })
        }

        ctrl.displayUserStories = true

        ctrl.toggleUserStoryList()

        expect(ctrl.displayUserStories).to.be.false
