###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

describe "ThemeService", ->
    themeService = null
    data = {
        theme: "testTheme"
    }

    _inject = () ->
        inject (_tgThemeService_) ->
            themeService = _tgThemeService_

    beforeEach ->
        module "taigaCommon"
        _inject()

    it "use a test theme", () ->
        window._version = '123'
        themeService.use(data.theme)
        expect($("link[rel='stylesheet']")).to.have.attr("href", "123/styles/theme-#{data.theme}.css")
