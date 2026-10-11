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

describe "Custom URL field policy", ->
    for value in [
        "obsidian://open?vault=vaultname&file=path%2Fto%2Fpage"
        "obsidian://open?file=docs%2Fmy%20page.md&vault=My%20Vault"
    ]
        do (value) ->
            it "allows #{value}", ->
                expect(taiga.isValidCustomFieldUrl(value)).to.equal(true)

    for action in ["new", "daily", "unique", "hook-get-address", "plugin-action"]
        do (action) ->
            it "rejects Obsidian action #{action}", ->
                expect(taiga.isValidCustomFieldUrl("obsidian://#{action}?vault=x&file=y")).to.equal(false)

    for key in ["append", "prepend", "path", "x-success", "x-error", "unknown"]
        do (key) ->
            it "rejects Obsidian parameter #{key}", ->
                expect(taiga.isValidCustomFieldUrl("obsidian://open?vault=x&file=y&#{key}=z")).to.equal(false)

    for value in [
        "obsidian://open"
        "obsidian://open?vault=x"
        "obsidian://open?file=y"
        "obsidian://open?vault=&file=y"
        "obsidian://open?vault=x&file="
        "obsidian://open?vault=x&file=y&vault=z"
        "obsidian://open?vault=x&file=y&file=z"
        "obsidian://open?vault=x&file=y&%76ault=z"
        "obsidian://user@open?vault=x&file=y"
        "obsidian://open:123?vault=x&file=y"
        "obsidian://open/path?vault=x&file=y"
        "obsidian://open/?vault=x&file=y"
        "obsidian://open?vault=x&file=y#section"
        "obsidian://open?vault=x&file=y#"
        "obsidian:open?vault=x&file=y"
        "javascript:alert(1)@example.com"
        "java\nscript:alert(1)@example.com"
        "data:text/html,user@example.com"
        "plugin:user@example.com"
        "https://"
        "not a URL"
        ""
        null
        123
    ]
        do (value) ->
            it "rejects unsafe or malformed value #{JSON.stringify(value)}", ->
                expect(taiga.isValidCustomFieldUrl(value)).to.equal(false)
