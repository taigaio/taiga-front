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
# File: components/file-change/file-change.directive.coffee
###

FileChangeDirective = ($parse) ->
    link = (scope, el, attrs, ctrl) ->
        eventAttr = $parse(attrs.tgFileChange)

        el.on 'change', (event) ->
            scope.$apply () -> eventAttr(scope, {files: event.currentTarget.files})

        scope.$on "$destroy", -> el.off()

    return {
        restrict: "A",
        link: link
    }

FileChangeDirective.$inject = [
    "$parse"
]

angular.module("taigaComponents").directive("tgFileChange", FileChangeDirective)
