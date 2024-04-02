###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "CommentsController", ->
    provide = null
    controller = null
    mocks = {}

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            return null

    beforeEach ->
        module "taigaHistory"
        _mocks()

        inject ($controller) ->
            controller = $controller

    it "set can add comment permission", () ->
        commentsCtrl = controller "CommentsCtrl"
        commentsCtrl.name = "us"
        commentsCtrl.initializePermissions()
        expect(commentsCtrl.canAddCommentPermission).to.be.equal("comment_us")
