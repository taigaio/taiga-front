###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
