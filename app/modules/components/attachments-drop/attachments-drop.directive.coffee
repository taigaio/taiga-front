###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
