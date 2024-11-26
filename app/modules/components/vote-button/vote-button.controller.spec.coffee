###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "VoteButton", ->
    provide = null
    $controller = null
    $rootScope = null
    mocks = {}

    _mockCurrentUser = () ->
        mocks.currentUser = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUser

    _mocks = ->
        mocks = {
            onUpvote: sinon.stub(),
            onDownvote: sinon.stub()
        }

        module ($provide) ->
            provide = $provide
            _mockCurrentUser()
            return null

    _inject = (callback) ->
        inject (_$controller_, _$rootScope_) ->
            $rootScope = _$rootScope_
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"
        _setup()

    it "upvote", (done) ->
        $scope = $rootScope.$new()

        mocks.onUpvote = sinon.stub().promise()

        ctrl = $controller("VoteButton", $scope, {
            item: {is_voter: false}
            onUpvote: mocks.onUpvote
            onDownvote: mocks.onDownvote
        })

        promise = ctrl.toggleVote()

        expect(ctrl.loading).to.be.true

        mocks.onUpvote.resolve()

        promise.finally () ->
            expect(mocks.onUpvote).to.be.calledOnce
            expect(ctrl.loading).to.be.false

            done()

    it "downvote", (done) ->
        $scope = $rootScope.$new()

        mocks.onDownvote = sinon.stub().promise()

        ctrl = $controller("VoteButton", $scope, {
            item: {is_voter: true}
            onUpvote: mocks.onUpvote
            onDownvote: mocks.onDownvote
        })

        promise = ctrl.toggleVote()

        expect(ctrl.loading).to.be.true

        mocks.onDownvote.resolve()

        promise.finally () ->
            expect(mocks.onDownvote).to.be.calledOnce
            expect(ctrl.loading).to.be.false

            done()
