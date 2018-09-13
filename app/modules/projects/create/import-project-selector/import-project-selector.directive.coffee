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
# File: projects/create/import-project-selector/import-project-selector.directive.coffee
###

ImportProjectSelectorDirective = () ->
    return {
        templateUrl:"projects/create/import-project-selector/import-project-selector.html",
        controller: "ImportProjectSelectorCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            projects: '<',
            onCancel: '&',
            onSelectProject: '&',
            logo: '@',
            noProjectsMsg: '@',
            search: '@'
        }
    }

angular.module("taigaProjects").directive("tgImportProjectSelector", ImportProjectSelectorDirective)
