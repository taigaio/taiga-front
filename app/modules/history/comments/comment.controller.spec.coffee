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
# File: history/comments/comment.controller.spec.coffee
###

describe "CommentController", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgCurrentUserService = () ->
        mocks.tgCurrentUserService = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.tgCurrentUserService

    _mockTgCheckPermissionsService = () ->
        mocks.tgCheckPermissionsService = {
            check: sinon.stub()
        }
        provide.value "tgCheckPermissionsService", mocks.tgCheckPermissionsService

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgCurrentUserService()
            _mockTgCheckPermissionsService()
            _mockTgLightboxFactory()
            return null

    beforeEach ->
        module "taigaHistory"
        _mocks()

        inject ($controller) ->
            controller = $controller

        commentsCtrl = controller "CommentCtrl"

        commentsCtrl.comment = "comment"
        commentsCtrl.hiddenDeletedComment = true
        commentsCtrl.commentContent = commentsCtrl.comment

    it "show deleted Comment", () ->
        commentsCtrl = controller "CommentCtrl"
        commentsCtrl.showDeletedComment()
        expect(commentsCtrl.hiddenDeletedComment).to.be.false

    it "hide deleted Comment", () ->
        commentsCtrl = controller "CommentCtrl"

        commentsCtrl.hiddenDeletedComment = false
        commentsCtrl.hideDeletedComment()
        expect(commentsCtrl.hiddenDeletedComment).to.be.true

    it "cancel comment on keyup", () ->
        commentsCtrl = controller "CommentCtrl"
        commentsCtrl.comment = {
            id: 2
        }
        event = {
            keyCode: 27
        }
        commentsCtrl.onEditMode = sinon.stub()
        commentsCtrl.checkCancelComment(event)

        expect(commentsCtrl.onEditMode).have.been.called

    it "can Edit Comment", () ->
        commentsCtrl = controller "CommentCtrl"

        commentsCtrl.user = Immutable.fromJS({
            id: 7
        })

        mocks.tgCurrentUserService.getUser.returns(commentsCtrl.user)

        commentsCtrl.comment = {
            user: {
                pk: 7
            }
        }

        mocks.tgCheckPermissionsService.check.withArgs('modify_project').returns(true)

        canEdit = commentsCtrl.canEditDeleteComment()
        expect(canEdit).to.be.true

    it "cannot Edit Comment", () ->
        commentsCtrl = controller "CommentCtrl"

        commentsCtrl.user = Immutable.fromJS({
            id: 8
        })

        mocks.tgCurrentUserService.getUser.returns(commentsCtrl.user)

        commentsCtrl.comment = {
            user: {
                pk: 7
            }
        }

        mocks.tgCheckPermissionsService.check.withArgs('modify_project').returns(false)

        canEdit = commentsCtrl.canEditDeleteComment()
        expect(canEdit).to.be.false
