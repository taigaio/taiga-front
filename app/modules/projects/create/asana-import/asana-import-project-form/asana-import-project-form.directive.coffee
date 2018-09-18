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
# File: projects/create/asana-import/asana-import-project-form/asana-import-project-form.directive.coffee
###

AsanaImportProjectFormDirective = () ->
    return {
        link: (scope, elm, attr, ctrl) ->
            scope.$watch('vm.members', ctrl.checkUsersLimit.bind(ctrl))

        templateUrl:"projects/create/asana-import/asana-import-project-form/asana-import-project-form.html",
        controller: "AsanaImportProjectFormCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            members: '<',
            project: '<',
            onSaveProjectDetails: '&',
            onCancelForm: '&',
            fetchingUsers: '<'
        }
    }

AsanaImportProjectFormDirective.$inject = []

angular.module("taigaProjects").directive("tgAsanaImportProjectForm", AsanaImportProjectFormDirective)
