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
# File: epics/related-userstories/related-userstories-create/related-userstories-create.directive.coffee
###

module = angular.module('taigaEpics')
debounceLeading = @.taiga.debounceLeading

RelatedUserstoriesCreateDirective = (@lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        newUserstoryForm = el.find(".new-user-story-form").checksley()
        existingUserstoryForm = el.find(".existing-user-story-form").checksley()

        ctrl.validateNewUserstoryForm = =>
            return newUserstoryForm.validate()

        ctrl.setNewUserstoryFormErrors = (errors) =>
            newUserstoryForm.setErrors(errors)

        ctrl.validateExistingUserstoryForm = =>
            return existingUserstoryForm.validate()

        ctrl.setExistingUserstoryFormErrors = (errors) =>
            existingUserstoryForm.setErrors(errors)

        scope.showLightbox = (selectedProjectId) ->
            ctrl.loadProjects()
            scope.selectProject(selectedProjectId).then () =>
                lightboxService.open(el.find(".lightbox-create-related-user-stories"))

        scope.closeLightbox = () ->
            scope.selectedUserstory = null
            scope.searchUserstory = ""
            scope.relatedUserstoriesText = ""
            lightboxService.close(el.find(".lightbox-create-related-user-stories"))

        scope.$watch 'vm.project', (project) ->
            if project?
              scope.selectedProject = project.get('id')

        scope.selectProject = (selectedProjectId) ->
            scope.selectedUserstory = null
            scope.searchUserstory = ""
            ctrl.filterUss(selectedProjectId, scope.searchUserstory)

        scope.onUpdateSearchUserstory = debounceLeading 300, () ->
            scope.selectedUserstory = null
            ctrl.filterUss(scope.selectedProject, scope.searchUserstory)

    return {
        link: link,
        templateUrl:"epics/related-userstories/related-userstories-create/related-userstories-create.html",
        controller: "RelatedUserstoriesCreateCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
              showCreateRelatedUserstoriesLightbox: "="
              project: "="
              epic: "="
              epicUserstories: "="
              loadRelatedUserstories:"&"
        }

    }

RelatedUserstoriesCreateDirective.$inject = ["lightboxService",]

module.directive("tgRelatedUserstoriesCreate", RelatedUserstoriesCreateDirective)
