###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

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
