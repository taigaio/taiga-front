###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: scope-event.service.coffee
###

class ScopeEvent
    scopes: {},
    _searchDuplicatedScopes: (id) ->
        return _.find Object.keys(@scopes), (key) =>
            return @scopes[key].$id == id

    _create: (name, scope) ->
        duplicatedScopeName = @._searchDuplicatedScopes(scope.$id)

        if duplicatedScopeName
            throw new Error("scopeEvent: this scope is already
            register with the name \"" + duplicatedScopeName + "\"")

        if @scopes[name]
            throw new Error("scopeEvent: \"" + name + "\" already in use")
        else
            scope._tgEmitter = new EventEmitter2()

            scope.$on "$destroy", () =>
                scope._tgEmitter.removeAllListeners()
                delete @scopes[name]

            @scopes[name] = scope

    emitter: (name, scope) ->
        if scope
            scope = @._create(name, scope)
        else if @scopes[name]
            scope = @scopes[name]
        else
            throw new Error("scopeEvent: \"" + name + "\" scope doesn't exist'")

        return scope._tgEmitter

angular.module("taigaCommon").service("tgScopeEvent", ScopeEvent)
