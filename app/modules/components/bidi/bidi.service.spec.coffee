###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgBidiService", ->
    bidiService = null

    beforeEach ->
        module "taigaComponents"

        inject (_tgBidiService_) ->
            bidiService = _tgBidiService_

    it "sets dir=auto on lists, quotes and tables only", ->
        root = document.createElement("div")
        root.innerHTML = "<ul><li>a</li></ul><ol></ol><blockquote><p>q</p></blockquote><table></table><p>text</p>"

        bidiService.apply(root)

        for selector in ["ul", "ol", "blockquote", "table"]
            expect(root.querySelector(selector).getAttribute("dir")).to.be.equal("auto")

        expect(root.querySelector("p").hasAttribute("dir")).to.be.false

    it "keeps containers marked after the content changes", (done) ->
        root = document.createElement("div")
        stop = bidiService.observe(root)

        root.innerHTML = "<ul><li>a</li></ul>"

        setTimeout (->
            expect(root.querySelector("ul").getAttribute("dir")).to.be.equal("auto")

            root.querySelector("ul").removeAttribute("dir")

            setTimeout (->
                expect(root.querySelector("ul").getAttribute("dir")).to.be.equal("auto")
                stop()
                done()
            ), 10
        ), 10
