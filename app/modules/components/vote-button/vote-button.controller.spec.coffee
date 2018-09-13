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
# File: components/vote-button/vote-button.controller.spec.coffee
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
