###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "Custom URL field rendering", ->
    element = scope = rootScope = compile = q = null
    repo = resources = null

    beforeEach ->
        module "templates", "taigaCommon", "ngSanitize"
        module ($provide) ->
            repo = {save: sinon.stub()}
            resources = {customAttributesValues: {userstory: {get: sinon.stub()}}}
            $provide.value "$tgRepo", repo
            $provide.value "$tgResources", resources
            $provide.value "$tgConfirm", {notify: sinon.stub()}
            $provide.value "$tgStorage", {get: -> false}
            $provide.value "$translate", {instant: (key) -> key}
            $provide.value "translateFilter", (key) -> key
            $provide.value "$selectedText", {get: -> ""}
            $provide.value "tgDatePickerConfigService", {get: -> {}}
            $provide.value "tgWysiwygService", {getHTML: (value) -> _.escape(value)}
            return null

        inject ($rootScope, $compile, $q) ->
            rootScope = $rootScope
            compile = $compile
            q = $q

    afterEach ->
        scope?.$destroy()
        element?.remove()

    mount = (attribute, storedValues) ->
        scope?.$destroy()
        element?.remove()
        scope = rootScope.$new()
        scope.project = {
            archived_code: null
            my_permissions: ["edit"]
            userstory_custom_attributes: [attribute]
        }
        scope.projectId = 1
        scope.story = {id: 42}
        resources.customAttributesValues.userstory.get.returns(q.when(storedValues))
        repo.save.returns(q.when(storedValues))
        element = compile("""
            <div tg-custom-attributes-values type="userstory"
                 required-edition-perm="edit" ng-model="story"></div>
        """)(scope)
        element.appendTo(document.body)
        scope.$digest()
        return element.find("[tg-custom-attribute-value]")

    for value in [
        "obsidian://new?vault=x&file=y"
        "obsidian://daily?vault=x"
        "obsidian://unique?vault=x"
        "obsidian://hook-get-address?foo=bar"
        "obsidian://plugin-action?foo=bar"
        "obsidian://open?vault=x&file=y&append=z"
        "obsidian://open?vault=x&file=y&file=z"
        "javascript:alert(1)"
        "javascript:alert(1)@example.com"
        "data:text/html,<script>alert(1)</script>"
        "data:text/html,{{7*7}}"
    ]
        do (value) ->
            it "keeps #{value} as text after TEXT becomes URL", ->
                attribute = {id: 1, name: "URL", description: "", type: "text"}
                storedValues = {attributes_values: {1: value}}
                mount(attribute, storedValues)
                attribute.type = "url"
                field = mount(attribute, storedValues)

                expect(field.find(".custom-field-value a")).to.have.length(0)
                expect(field.find(".custom-field-value span").text()).to.equal(value)
                expect(storedValues.attributes_values[1]).to.equal(value)
                expect(repo.save).not.to.have.been.called

    it "renders a safe stored Obsidian open URL as a link after TEXT becomes URL", ->
        value = "obsidian://open?vault=x&file=y"
        attribute = {id: 1, name: "URL", description: "", type: "text"}
        storedValues = {attributes_values: {1: value}}
        mount(attribute, storedValues)
        attribute.type = "url"
        field = mount(attribute, storedValues)

        expect(field.find(".custom-field-value a")).to.have.attr("href", value)
        expect(storedValues.attributes_values[1]).to.equal(value)

    it "does not compile expressions in a stored URL", ->
        value = "obsidian://open?vault=x&file={{7*7}}"
        field = mount({id: 1, name: "URL", description: "", type: "url"}, {
            attributes_values: {1: value}
        })
        expect(field.find(".custom-field-value a")).to.have.attr("href", value)
        expect(field.find(".custom-field-value span").text()).to.equal(value)
