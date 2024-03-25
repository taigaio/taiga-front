###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgLightboxFactory", ->
    lightboxFactoryService = provide = null
    mocks = {}

    _mockRootScope = () ->
        mocks.rootScope = sinon.stub()
        provide.value "$rootScope", {$new: mocks.rootScope}

    _mockCompile = () ->
        mocks.compile = sinon.stub()
        fn = () -> "<p id='fake'>fake</p>"
        mocks.compile.returns(fn)
        provide.value "$compile", mocks.compile

    _inject = (callback) ->
        inject (_tgLightboxFactory_) ->
            lightboxFactoryService = _tgLightboxFactory_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockRootScope()
            _mockCompile()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    it "insert directive", () ->
        lightboxFactoryService.create("fake-directive")

        expect($(document.body).find("#fake")).to.have.length(1)

    it "directive must have the tg-bind-scope directive", () ->
        lightboxFactoryService.create("fake-directive")

        checkDirective = sinon.match ( (value) ->
            return value.attr("tg-bind-scope")
        ), "checkDirective"

        expect(mocks.compile.withArgs(checkDirective)).to.have.been.calledOnce

    it "custom attributes", () ->
        attrs = {
            "class": "x1",
            "id": "x2"
        }

        lightboxFactoryService.create("fake-directive", attrs)

        checkAttributes = sinon.match ( (value) ->
            return value.hasClass("x1") && value.attr("id") == "x2" && value.hasClass("remove-on-close")
        ), "checkAttributes"

        expect(mocks.compile.withArgs(checkAttributes)).to.have.been.calledOnce

    it "directive has class remove-on-close", () ->
        lightboxFactoryService.create("fake-directive")

        checkClass = sinon.match ( (value) ->
            return value.hasClass("remove-on-close")
        ), "checkClass"

        expect(mocks.compile.withArgs(checkClass)).to.have.been.calledOnce
