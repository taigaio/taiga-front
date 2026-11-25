###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

# Content-driven bidi support. Text blocks are handled in CSS
# (unicode-bidi: plaintext, see styles/core/bidi.scss); containers whose box
# direction matters (list marker side, quote border, table column order) get
# dir="auto" so the browser resolves it from their first strong character.

BIDI_CONTAINERS = "ul, ol, blockquote, table"

class BidiService extends taiga.Service
    # Set dir="auto" on every container below `root`. Idempotent.
    apply: (root) ->
        return if not root
        nodes = root.querySelectorAll(BIDI_CONTAINERS)
        for node in nodes
            @._mark(node)
        return

    # Keep containers marked while the content changes (CKEditor re-renders
    # nodes and may drop foreign attributes). Returns a function that stops it.
    observe: (root) ->
        return (->) if not root or not window.MutationObserver

        @.apply(root)

        observer = new MutationObserver (mutations) =>
            for mutation in mutations
                if mutation.type == "attributes"
                    @._mark(mutation.target) if mutation.target.matches?(BIDI_CONTAINERS)
                else
                    for node in mutation.addedNodes
                        continue if node.nodeType != 1
                        @._mark(node) if node.matches(BIDI_CONTAINERS)
                        @.apply(node)
            return

        observer.observe(root, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ["dir"]
        })

        return -> observer.disconnect()

    _mark: (node) ->
        if node.getAttribute("dir") != "auto"
            node.setAttribute("dir", "auto")

angular.module("taigaComponents").service("tgBidiService", BidiService)

# Marks the wysiwyg/editor area it is placed on (tg-bidi-observe).
BidiObserveDirective = (bidiService) ->
    link = (scope, el) ->
        stop = bidiService.observe(el[0])
        scope.$on "$destroy", stop

    return {restrict: "A", link: link}

angular.module("taigaComponents").directive("tgBidiObserve", ["tgBidiService", BidiObserveDirective])
