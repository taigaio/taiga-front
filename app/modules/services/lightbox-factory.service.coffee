class LightboxFactory
    @.$inject = ["$rootScope", "$compile"]
    constructor: (@rootScope, @compile) ->

    create: (name, attrs, scopeAttrs) ->
        scope = @rootScope.$new()

        scope = _.merge(scope, scopeAttrs)

        elm = $("<div>")
            .attr(name, true)
            .attr("tg-bind-scope", true)

        if attrs
            elm.attr(attrs)

        elm.addClass("remove-on-close")

        html = @compile(elm)(scope)

        $(document.body).append(html)

        return

angular.module("taigaCommon").service("tgLightboxFactory", LightboxFactory)
