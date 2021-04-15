###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
