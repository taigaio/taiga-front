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
        "ftp://example.com/path"
        "sftp://example.com/path"
        "git://example.com/project.git"
        "example.com/path"
        "example.com:8080/path"
        "example.com:8080?query=value#section"
        "192.168.1.1:8080/path"
        "https://user:pass@example.com:8443/path?query=value#section"
        "http://192.168.1.1/path"
        "https://例え.テスト/path"
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
        "javascript:alert(1)@example.com"
        "user:pass@example.com"
        "user:8080@example.com"
        "user_name:pass@example.com"
        "123:pass@example.com"
        "javascript:8080"
        "example.com:not-a-port/path"
        "obsidian://open?vault=x&file=y&append=z"
        "obsidian://open?vault=x&file=y&file=z"
    ]
        do (value) ->
            it "rejects #{value}", ->
                expect(validate(value)).to.equal(false)

    it "keeps invalid values in the editor and displays a Checksley error", ->
        value = "obsidian://new?vault=x&file=y"
        expect(validate(value)).to.equal(false)
        expect(form.find("input[name=value]").val()).to.equal(value)
        expect(form.find(".checksley-error-list li")).to.have.length(1)

    it "still allows an optional URL field to be cleared", ->
        expect(validate("")).to.equal(true)

    it "does not allow Obsidian in other Checksley URL inputs", ->
        form = $('<form><input name="value" type="url" data-type="url"></form>')
        form.find("input").val("obsidian://open?vault=x&file=y")
        form.appendTo(document.body)
        expect(form.checksley().validate()).to.equal(false)

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
        "obsidian://@open?vault=x&file=y"
        "obsidian://:@open?vault=x&file=y"
        "obsidian://open:?vault=x&file=y"
        "obsidian://OPEN?vault=x&file=y"
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

    it "preserves existing URLs when the native URL parser is unavailable", ->
        originalURL = window.URL
        try
            window.URL = undefined
            expect(taiga.isValidCustomFieldUrl("https://example.com")).to.equal(true)
            expect(taiga.isValidCustomFieldUrl("mailto:user@example.com")).to.equal(true)
            expect(taiga.isValidCustomFieldUrl("example.com:8080/path")).to.equal(true)
            expect(taiga.isValidCustomFieldUrl("obsidian://open?vault=x&file=y")).to.equal(false)
        finally
            window.URL = originalURL

    it "rejects Obsidian if the native parser cannot inspect query parameters", ->
        originalURL = window.URL
        parsedURL = new URL("obsidian://open?vault=x&file=y")
        Object.defineProperty(parsedURL, "searchParams", {value: undefined})
        try
            window.URL = -> parsedURL
            expect(taiga.isValidCustomFieldUrl("obsidian://open?vault=x&file=y")).to.equal(false)
        finally
            window.URL = originalURL
