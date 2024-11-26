###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
