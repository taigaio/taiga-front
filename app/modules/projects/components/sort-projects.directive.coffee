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
