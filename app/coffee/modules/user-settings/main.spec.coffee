###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
###

describe "User settings inheritance", ->
    scope = user = config = controller = null

    beforeEach ->
        module "taigaUserSettings"

        inject ($controller, $rootScope, $q) ->
            scope = $rootScope.$new()
            user = {lang: "", theme: ""}
            config = {
                get: (name, fallback) ->
                    return ["taiga", "taiga-dark"] if name == "themes"
                    return "taiga" if name == "defaultTheme"
                    return "pt-br" if name == "defaultLanguage"
                    return fallback
            }
            window._taigaAvailableThemes = ["taiga", "taiga-dark"]
            controller = $controller "UserSettingsController", {
                "$scope": scope
                "$rootScope": $rootScope
                "$tgConfig": config
                "$tgRepo": {}
                "$tgConfirm": {}
                "$tgResources": {locales: {list: -> $q.when([])}}
                "$routeParams": {}
                "$q": $q
                "$tgLocation": {}
                "$tgNavUrls": {}
                "$tgAuth": {getUser: -> user}
                "$translate": {preferredLanguage: -> "pt-br"}
                "tgErrorHandlingService": {}
                "$window": window
            }

    it "keeps blank account choices while showing effective defaults", ->
        expect(scope.lang).to.equal("")
        expect(scope.theme).to.equal("")
        expect(scope.effectiveLang).to.equal("pt-br")
        expect(scope.effectiveTheme).to.equal("taiga")

    it "does not show a compiled theme disabled by configuration", ->
        user.theme = "taiga-dark"
        config.get = (name, fallback) ->
            return ["taiga"] if name == "themes"
            return "taiga-dark" if name == "defaultTheme"
            return fallback
        expect(controller.getTheme()).to.equal("taiga")

    it "shows the valid system default when the account theme is disabled", ->
        user.theme = "custom-removed"
        config.get = (name, fallback) ->
            return ["taiga", "taiga-dark"] if name == "themes"
            return "taiga-dark" if name == "defaultTheme"
            return fallback
        expect(controller.getTheme()).to.equal("taiga-dark")

    it "shows system defaults when the account has overrides", ->
        user.lang = "en"
        user.theme = "taiga-dark"
        expect(scope.effectiveLang).to.equal("pt-br")
        expect(controller.getTheme()).to.equal("taiga")
