###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: sort-projects.directive.coffee
###

SortProjectsDirective = (currentUserService) ->
    link = (scope, el, attrs, ctrl) ->
        itemEl = null

        el.sortable({
            dropOnEmpty: true
            revert: 200
            axis: "y"
            opacity: .95
            placeholder: 'placeholder'
            cancel: '.project-name'
        })

        el.on "sortstop", (event, ui) ->
            itemEl = ui.item
            project = itemEl.scope().project
            index = itemEl.index()

            sorted_project_ids = _.map(scope.projects.toJS(), (p) -> p.id)
            sorted_project_ids = _.without(sorted_project_ids, project.get("id"))
            sorted_project_ids.splice(index, 0, project.get('id'))

            sortData = []

            for value, index in sorted_project_ids
                sortData.push({"project_id": value, "order":index})

            currentUserService.bulkUpdateProjectsOrder(sortData)

    directive = {
        scope: {
            projects: "=tgSortProjects"
        },
        link: link
    }

    return directive

angular.module("taigaProjects").directive("tgSortProjects", ["tgCurrentUserService", SortProjectsDirective])
