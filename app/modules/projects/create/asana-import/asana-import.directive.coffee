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
# File: projects/create/asana-import/asana-import.directive.coffee
###

AsanaImportDirective = () ->
    return {
        link: (scope, elm, attrs, ctrl) ->
            ctrl.startProjectSelector()
        templateUrl:"projects/create/asana-import/asana-import.html",
        controller: "AsanaImportCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancel: '&'
        }
    }

AsanaImportDirective.$inject = []

angular.module("taigaProjects").directive("tgAsanaImport", AsanaImportDirective)
