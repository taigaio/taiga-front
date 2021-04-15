###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

# This directive call a function when the html element has loaded

# ```jade
#     div(
#         tg-loaded="callbackFn"
#     )
# ```
module = angular.module("taigaCommon")

Loaded = ($parse, $timeout) ->
    return {
        restrict: 'A',
        compile: ($element, $attrs) ->
            fn = $parse($attrs['tgLoaded'])

            return ($scope, $element) ->
                callback = () ->
                    fn(
                        $scope,
                        {
                            $event: {
                                target: $element
                            }
                        }
                    )

                $timeout () -> callback()

                return null
    }

module.directive("tgLoaded", ['$parse', '$timeout', Loaded])
