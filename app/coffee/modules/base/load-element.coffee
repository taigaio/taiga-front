###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: modules/base/navurls.coffee
###

taiga = @.taiga

# https://stackoverflow.com/questions/12371159/how-to-get-evaluated-attributes-inside-a-custom-directive
# https://stackoverflow.com/questions/18637803/how-can-i-parse-an-attribute-directive-which-has-multiple-values
# https://github.com/angular/angular.js/blob/master/src/ng/directive/ngClass.js#L146

module = angular.module("taigaBase")

LoadElementDirective = ($parse) ->
    link = ($scope, $el, $attrs) ->
        $scope.$watch $parse($attrs.tgLoadElement), (val) ->
            if val
                legacyObj =  $parse($attrs.tgLoadElement)($scope)

                $el[0].component = legacyObj.component

                if legacyObj.params
                    $el[0].params = legacyObj.params

    return {
        link: link
    }

module.directive("tgLoadElement", ['$parse', LoadElementDirective])
