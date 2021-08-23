###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "tgProjectLogoService", ->
    $provide = null
    projectLogoService = null

    _inject = ->
        inject (_tgProjectLogoService_) ->
            projectLogoService = _tgProjectLogoService_

    _setup = ->
        _inject()

    beforeEach ->
        window._version = '123'
        module "taigaCommon"

        _setup()

    it "get default project logo", () ->

        logo = projectLogoService.getDefaultProjectLogo('slug/slug', 2)

        expect(logo.src).to.be.equal('123/images/project-logos/project-logo-04.png')
        expect(logo.color).to.be.equal('rgba( 152, 224, 168,  1 )')
