###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

JoyRideDirective = ($rootScope, currentUserService, joyRideService, $location, $translate) ->
    link = (scope, el, attrs, ctrl) ->
        unsuscribe = null
        intro = introJs()

        intro.oncomplete () ->
            $('html,body').scrollTop(0)

        intro.onexit () ->
            currentUserService.disableJoyRide()

        initJoyrRide = (next, config) ->
            if !config[next.joyride]
                return

            intro.setOptions({
                exitOnEsc: false,
                exitOnOverlayClick: false,
                showStepNumbers: false,
                nextLabel: $translate.instant('JOYRIDE.NAV.NEXT') + ' &rarr;',
                prevLabel: '&larr; ' + $translate.instant('JOYRIDE.NAV.BACK'),
                skipLabel: $translate.instant('JOYRIDE.NAV.SKIP'),
                doneLabel: $translate.instant('JOYRIDE.NAV.DONE'),
                disableInteraction: true
            })

            intro.setOption('steps', joyRideService.get(next.joyride))
            intro.start()

        $rootScope.$on '$routeChangeSuccess',  (event, next) ->
            if !next.joyride || !currentUserService.isAuthenticated()
                intro.exit()
                unsuscribe() if unsuscribe
                return


            intro.oncomplete () ->
                currentUserService.disableJoyRide(next.joyride)

            if next.loader
                unsuscribe = $rootScope.$on 'loader:end',  () ->
                    currentUserService.loadJoyRideConfig()
                        .then (config) -> initJoyrRide(next, config)

                    unsuscribe()
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
    "tgJoyRideService",
    "$location",
    "$translate"
]

angular.module("taigaComponents").directive("tgJoyRide", JoyRideDirective)
