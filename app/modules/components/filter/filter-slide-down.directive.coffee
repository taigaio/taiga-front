###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

FilterSlideDownDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        filter = $('tg-filter')

        scope.$watch attrs.ngIf, (value) ->
            if value
                filter.find('.filter-list').hide()

                wrapperHeight = filter.height()
                contentHeight = 0

                filter.children().each () ->
                    contentHeight += $(this).outerHeight(true)

                $(el.context.nextSibling)
                    .css({
                        "display": "block"
                    })

    return {
        priority: 900,
        link: link
    }

angular.module('taigaComponents').directive("tgFilterSlideDown", [FilterSlideDownDirective])
