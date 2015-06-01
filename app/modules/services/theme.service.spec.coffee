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
        themeService.use(data.theme)
        expect($("link[rel='stylesheet']")).to.have.attr("href", "/styles/theme-#{data.theme}.css")
