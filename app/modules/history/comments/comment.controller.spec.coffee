###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
