###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

SortProjectsDirective = (currentUserService) ->
    link = (scope, el, attrs, ctrl) ->
        itemEl = null

        drake = dragula([el[0]], {
            copySortSource: false,
            copy: false,
            mirrorContainer: el[0],
            moves: (item) -> return $(item).hasClass('list-itemtype-project')
        })

        drake.on 'dragend', (item) ->
            itemEl = $(item)
            project = itemEl.scope().project
            index = itemEl.index()

            sorted_project_ids = _.map(scope.projects.toJS(), (p) -> p.id)
            sorted_project_ids = _.without(sorted_project_ids, project.get("id"))
            sorted_project_ids.splice(index, 0, project.get('id'))

            sortData = []

            for value, index in sorted_project_ids
                sortData.push({"project_id": value, "order":index})

            currentUserService.bulkUpdateProjectsOrder(sortData)

        scroll = autoScroll(window, {
            margin: 20,
            pixels: 30,
            scrollWhenOutside: true,
            autoScroll: () ->
                return this.down && drake.dragging
        })

        scope.$on "$destroy", ->
            el.off()
            drake.destroy()

    directive = {
        scope: {
            projects: "=tgSortProjects"
        },
        link: link
    }

    return directive

angular.module("taigaProjects").directive("tgSortProjects", ["tgCurrentUserService", SortProjectsDirective])
