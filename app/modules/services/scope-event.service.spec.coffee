angular.module("taigaCommon").provider("$exceptionHandler", angular.mock.$ExceptionHandlerProvider)

describe.only "tgScopeEvent", ->
    scopeEvent = null
    $rootScope = null

    _inject = ->
        inject (_tgScopeEvent_, _$rootScope_) ->
            scopeEvent = _tgScopeEvent_
            scopeEvent.scopes = {}

            $rootScope = _$rootScope_

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaCommon"
        _setup()

    it "get non-existent emitter", () ->
        fn = () -> scopeEvent.emitter("test")

        expect(fn).to.throw(Error, "scopeEvent: \"test\" scope doesn't exist'")

    it "create emitter", () ->
        scope = $rootScope.$new()

        emitter = scopeEvent.emitter("test", scope)

        expect(emitter).to.be.an.instanceof(EventEmitter2)

    it "get emitter", () ->
        scope = $rootScope.$new()

        scopeEvent.emitter("test", scope)

        emitter = scopeEvent.emitter("test")

        expect(emitter).to.be.an.instanceof(EventEmitter2)

    it "duplicate emitter name", () ->
        scope = $rootScope.$new()
        scope2 = $rootScope.$new()

        scopeEvent.emitter("test", scope)

        fn = () -> scopeEvent.emitter("test", scope2)

        expect(fn).to.throw(Error, "scopeEvent: \"test\" already in use")

    it "duplicate scope", () ->
        scope = $rootScope.$new()

        scopeEvent.emitter("test", scope)

        fn = () -> scopeEvent.emitter("test2", scope)

        expect(fn).to.throw(Error, "scopeEvent: this scope is already register with the name \"test\"")


    it "create listener", () ->
        scope = $rootScope.$new()

        emitter = scopeEvent.emitter("test", scope)
        emitter.on "test_listener", () -> return

        expect(scope._tgEmitter.listeners("test_listener")[0]).to.be.ok

    it "remove emitter and listeners after scope destroy", () ->
        scope = $rootScope.$new()

        emitter = scopeEvent.emitter("test", scope)

        emitter.on "test_listener", () -> return

        expect(scope._tgEmitter.listeners("test_listener")).to.have.length(1)

        expect(scopeEvent.scopes['test']).to.be.ok
        scope.$destroy()

        expect(scopeEvent.scopes['test']).to.be.undefined
        expect(scope._tgEmitter.listeners("test_listener")).to.have.length(0)
