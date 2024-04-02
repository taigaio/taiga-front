###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
