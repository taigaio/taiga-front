CompileHtmlDirective = ($compile) ->
    link = (scope, element, attrs) ->
        scope.$watch attrs.tgCompileHtml, (newValue, oldValue) ->
            element.html(newValue)
            $compile(element.contents())(scope)

    return {
        link: link
    }

CompileHtmlDirective.$inject = ["$compile"]

angular.module("taigaCommon").directive("tgCompileHtml", CompileHtmlDirective)
