###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

AttachmentsDropDirective = ($parse) ->
    link = (scope, el, attrs) ->
        eventAttr = $parse(attrs.tgAttachmentsDrop)

        el.on 'dragover', (e) ->
            e.preventDefault()
            e.currentTarget.classList.add('attachment-dragover')
            return false

        el.on 'dragleave', (e) ->
            e.preventDefault()
            e.currentTarget.classList.remove('attachment-dragover')
            return false

        el.on 'drop', (e) ->
            e.stopPropagation()
            e.preventDefault()

            e.currentTarget.classList.remove('attachment-dragover')

            dataTransfer = e.dataTransfer || (e.originalEvent && e.originalEvent.dataTransfer)

            scope.$apply () -> eventAttr(scope, {files: dataTransfer.files})

        scope.$on "$destroy", -> el.off()

    return {
        link: link
    }

AttachmentsDropDirective.$inject = [
    "$parse"
]

angular.module("taigaComponents").directive("tgAttachmentsDrop", AttachmentsDropDirective)
