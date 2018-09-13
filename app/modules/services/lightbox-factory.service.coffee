###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: services/lightbox-factory.service.coffee
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
