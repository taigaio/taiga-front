class LightboxFactory
    @.$inject = ["$rootScope", "$compile"]
    constructor: (@rootScope, @compile) ->

    create: (name) ->
        scope = @rootScope.$new()

        elm = $("<div>")
            .attr(name, true)
            .attr("tg-bind-scope", true)
            .addClass("wizard-create-project")
            .addClass("remove-on-close")

        html = @compile(elm)(scope)

        $(document.body).append(html)

        return

angular.module("taigaCommon").service("tgLightboxFactory", LightboxFactory)
