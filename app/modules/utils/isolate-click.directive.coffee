IsolateClickDirective = () ->
    link = (scope, el, attrs) ->
        el.on 'click', (e) =>
            e.stopPropagation()

    return {link: link}

angular.module("taigaUtils").directive("tgIsolateClick", IsolateClickDirective)
