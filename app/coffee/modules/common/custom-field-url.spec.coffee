###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "Custom URL field validation", ->
    form = template = null

    beforeEach ->
        module "templates"
        inject ($templateCache) ->
            template = _.template($templateCache.get("custom-attributes/custom-attribute-value-edit.html"))

    afterEach ->
        form?.data("checksley")?.destroy()
        form?.remove()

    validate = (value) ->
        form = $(template({type: "url", name: "URL", description: "", value: value}))
        form.appendTo(document.body)
        return form.checksley().validate()

    for value in [
        "https://example.com"
        "http://example.com/path"
        "mailto:user@example.com"
        "obsidian://open?vault=vaultname&file=path%2Fto%2Fpage"
    ]
        do (value) ->
            it "accepts #{value}", ->
                expect(validate(value)).to.equal(true)

    for value in [
        "obsidian://new?vault=x&file=y"
        "obsidian://daily?vault=x"
        "obsidian://unique?vault=x"
        "obsidian://hook-get-address?foo=bar"
        "obsidian://plugin-action?foo=bar"
        "javascript:alert(1)"
        "data:text/html,<script>alert(1)</script>"
    ]
        do (value) ->
            it "rejects #{value}", ->
                expect(validate(value)).to.equal(false)
