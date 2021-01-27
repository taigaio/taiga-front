###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: modules/common/loaded.coffee
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
