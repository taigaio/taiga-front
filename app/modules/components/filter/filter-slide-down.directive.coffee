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
