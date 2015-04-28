class LightboxFactory
    @.$inject = ["$rootScope", "$compile"]
    constructor: (@rootScope, @compile) ->

    create: (name, attrs) ->
        scope = @rootScope.$new()

        elm = $("<div>")
            .attr(name, true)
            .attr("tg-bind-scope", true)
            .addClass("remove-on-close")

        if attrs
            elm.attr(attrs)

        html = @compile(elm)(scope)

        $(document.body).append(html)

        return

angular.module("taigaCommon").service("tgLightboxFactory", LightboxFactory)
