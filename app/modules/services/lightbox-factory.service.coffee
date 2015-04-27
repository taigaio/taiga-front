class LightboxFactory
    @.$inject = ["$rootScope", "$compile"]
    constructor: (@rootScope, @compile) ->

    create: (name) ->
        elm = $("<div>")
            .attr(name, true)
            .addClass("wizard-create-project")
            .addClass("remove-on-close")

        scope = @rootScope.$new()
        html = @compile(elm)(scope)

        $(document.body).append(html)

        return

angular.module("taigaCommon").service("tgLightboxFactory", LightboxFactory)
