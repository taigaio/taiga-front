taiga = @.taiga

JoyRideDirective = ($rootScope, currentUserService, joyRideService) ->
    link = (scope, el, attrs, ctrl) ->
        intro = introJs()

        #Todo: translate
        intro.setOptions({
            exitOnEsc: false,
            exitOnOverlayClick: false,
            nextLabel: 'Next &rarr;',
            prevLabel: '&larr; Back',
            skipLabel: 'Skip',
            doneLabel: 'Done'
        })

        intro.oncomplete () ->
            $('html,body').scrollTop(0)

        startIntro = (joyRideName) ->
            intro.setOption('steps', joyRideService.get(joyRideName))
            intro.start();

        $rootScope.$on '$routeChangeSuccess',  (event, next) ->
            return if !next.joyride || !currentUserService.isAuthenticated()

            if next.loader
                un = $rootScope.$on 'loader:end',  () ->
                    startIntro(next.joyride)
                    un()
            else
                startIntro(next.joyride)

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
