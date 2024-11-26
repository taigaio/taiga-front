###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "LikeProjectButton", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockTgConfirm = ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        $provide.value("$tgConfirm", mocks.tgConfirm)

    _mockTgLikeProjectButton = ->
        mocks.tgLikeProjectButton = {
            like: sinon.stub(),
            unlike: sinon.stub()
        }

        $provide.value("tgLikeProjectButtonService", mocks.tgLikeProjectButton)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTgConfirm()
            _mockTgLikeProjectButton()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "toggleLike false -> true", (done) ->
        project = Immutable.fromJS({
            id: 3,
            is_fan: false
        })

        ctrl = $controller("LikeProjectButton")
        ctrl.project = project

        mocks.tgLikeProjectButton.like = sinon.stub().promise()

        promise = ctrl.toggleLike()

        expect(ctrl.loading).to.be.true

        mocks.tgLikeProjectButton.like.withArgs(project.get('id')).resolve()

        promise.finally () ->
            expect(mocks.tgLikeProjectButton.like).to.be.calledOnce
            expect(ctrl.loading).to.be.false

            done()

    it "toggleLike false -> true, notify error", (done) ->
        project = Immutable.fromJS({
            id: 3,
            is_fan: false
        })

        ctrl = $controller("LikeProjectButton")
        ctrl.project = project

        mocks.tgLikeProjectButton.like.withArgs(project.get('id')).promise().reject(new Error('error'))

        ctrl.toggleLike().finally () ->
            expect(mocks.tgConfirm.notify.withArgs("error")).to.be.calledOnce
            done()

    it "toggleLike true -> false", (done) ->
        project = Immutable.fromJS({
            is_fan: true
        })

        ctrl = $controller("LikeProjectButton")
        ctrl.project = project

        mocks.tgLikeProjectButton.unlike = sinon.stub().promise()

        promise = ctrl.toggleLike()

        expect(ctrl.loading).to.be.true

        mocks.tgLikeProjectButton.unlike.withArgs(project.get('id')).resolve()

        promise.finally () ->
            expect(mocks.tgLikeProjectButton.unlike).to.be.calledOnce
            expect(ctrl.loading).to.be.false

            done()

    it "toggleLike true -> false, notify error", (done) ->
        project = Immutable.fromJS({
            is_fan: true
        })

        ctrl = $controller("LikeProjectButton")
        ctrl.project = project

        mocks.tgLikeProjectButton.unlike.withArgs(project.get('id')).promise().reject(new Error('error'))

        ctrl.toggleLike().finally () ->
            expect(mocks.tgConfirm.notify.withArgs("error")).to.be.calledOnce
            done()
