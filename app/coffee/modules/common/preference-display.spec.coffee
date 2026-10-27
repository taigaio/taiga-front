###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
###

describe "Preference display filters", ->
    labels = filters = compile = rootScope = null

    beforeEach ->
        labels = {"THEMES.LIGHT": "Light", "THEMES.DARK": "Dark"}
        module "taigaCommon"
        module ($provide) ->
            $provide.value "$translate", {instant: (key) -> labels[key] || key}
            return null

        inject ($filter, $compile, $rootScope) ->
            filters = $filter
            compile = $compile
            rootScope = $rootScope

    it "translates built-in themes and preserves unknown names", ->
        themeName = filters("themeName")
        expect(themeName("taiga")).to.equal("Light")
        expect(themeName("taiga-dark")).to.equal("Dark")
        expect(themeName("custom-theme")).to.equal("custom-theme")
        labels["THEMES.LIGHT"] = "Claro"
        expect(themeName("taiga")).to.equal("Claro")

    it "displays a translated choice while retaining the theme code", ->
        scope = rootScope.$new()
        scope.themes = ["taiga", "taiga-dark"]
        scope.theme = "taiga-dark"
        element = compile('<select ng-model="theme" ng-options="theme as (theme | themeName) for theme in themes"></select>')(scope)
        scope.$digest()
        expect(element[0].selectedOptions[0].textContent).to.equal("Dark")
        expect(scope.theme).to.equal("taiga-dark")

    it "uses backend locale self-names for an inherited language", ->
        localeName = filters("localeName")
        locales = [{code: "en", name: "English (US)"}, {code: "pt-br", name: "Português (Brasil)"}]
        expect(localeName("pt-br", locales)).to.equal("Português (Brasil)")
        expect(localeName("en", locales)).to.equal("English (US)")
        expect(localeName("custom", locales)).to.equal("custom")
