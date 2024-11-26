###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
