###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

FileChangeDirective = ($parse) ->
    link = (scope, el, attrs, ctrl) ->
        eventAttr = $parse(attrs.tgFileChange)

        el.on 'change', (event) ->
            scope.$apply () -> eventAttr(scope, {files: event.currentTarget.files})

        scope.$on "$destroy", -> el.off()

    return {
        restrict: "A",
        link: link
    }

FileChangeDirective.$inject = [
    "$parse"
]

angular.module("taigaComponents").directive("tgFileChange", FileChangeDirective)
