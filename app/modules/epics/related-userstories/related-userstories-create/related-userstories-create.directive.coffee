###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
