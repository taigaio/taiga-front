locationFactory = ($location, $route, $rootscope) ->
    $location.noreload =  (scope) ->
        lastRoute = $route.current
        un = scope.$on "$locationChangeSuccess", ->
            $route.current = lastRoute
            un()

        return $location

    $location.isInCurrentRouteParams = (name, value) ->
        params = $location.search() || {}

        return params[name] == value

    return $location


module = angular.module("taigaBase")
module.factory("$tgLocation", ["$location", "$route", "$rootScope", locationFactory])
