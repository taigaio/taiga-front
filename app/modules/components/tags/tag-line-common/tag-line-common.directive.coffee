###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module('taigaCommon')

TagLineCommonDirective = () ->
    link = (scope, el, attr, ctrl) ->
        if !_.isUndefined(attr.disableColorSelection)
            ctrl.disableColorSelection = true

        unwatch = scope.$watch "vm.project", (project) ->
            return if !project || !Object.keys(project).length

            unwatch()

            if not ctrl.disableColorSelection
                ctrl.colorArray = ctrl._createColorsArray(ctrl.project.tags_colors)

        el.on "keydown", ".tag-input", (event) ->
            if event.keyCode == 27
                ctrl.addTag = false

                ctrl.newTag.name = ""
                ctrl.newTag.color = ""

                event.stopPropagation()
            else if event.keyCode == 13
                event.preventDefault()

                if el.find('.tags-dropdown .selected').length
                    tagName = $('.tags-dropdown .selected .tags-dropdown-name').text()
                    ctrl.addNewTag(tagName, null)
                else
                    ctrl.addNewTag(ctrl.newTag.name, ctrl.newTag.color)

            scope.$apply()

    return {
        link: link,
        scope: {
            permissions: "@",
            loadingAddTag: "=",
            loadingRemoveTag: "=",
            tags: "=",
            project: "=",
            onAddTag: "&",
            onDeleteTag: "&"
        },
        templateUrl:"components/tags/tag-line-common/tag-line-common.html",
        controller: "TagLineCommonCtrl",
        controllerAs: "vm",
        bindToController: true
    }

module.directive("tgTagLineCommon", TagLineCommonDirective)
