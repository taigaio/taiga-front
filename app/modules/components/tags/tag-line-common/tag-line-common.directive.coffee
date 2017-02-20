###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: tag-line.directive.coffee
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
