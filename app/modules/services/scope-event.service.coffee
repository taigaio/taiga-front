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
