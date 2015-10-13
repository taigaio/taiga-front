taiga = @.taiga

JoyRideDirective = ($rootScope, currentUserService, joyRideService) ->
    link = (scope, el, attrs, ctrl) ->
        intro = introJs()

        #Todo: translate
        intro.setOptions({
            exitOnEsc: false,
            exitOnOverlayClick: false,
            showStepNumbers: false,
            nextLabel: 'Next &rarr;',
            prevLabel: '&larr; Back',
            skipLabel: 'Skip',
            doneLabel: 'Done'
        })

        intro.oncomplete () ->
            $('html,body').scrollTop(0)

        intro.onexit () ->
            currentUserService.disableJoyRide()

        initJoyrRide = (next, config) ->
            if !config[next.joyride]
                return

            intro.setOption('steps', joyRideService.get(next.joyride))
            intro.start()

        $rootScope.$on '$routeChangeSuccess',  (event, next) ->
            return if !next.joyride || !currentUserService.isAuthenticated()

            intro.oncomplete () ->
                currentUserService.disableJoyRide(next.joyride)

            if next.loader
                un = $rootScope.$on 'loader:end',  () ->
                    currentUserService.loadJoyRideConfig()
                        .then (config) -> initJoyrRide(next, config)

                    un()
            else
                currentUserService.loadJoyRideConfig()
                    .then (config) -> initJoyrRide(next, config)

    return {
        scope: {},
        link: link
    }

JoyRideDirective.$inject = [
    "$rootScope",
    "tgCurrentUserService",
    "tgJoyRideService"
]

angular.module("taigaComponents").directive("tgJoyRide", JoyRideDirective)
