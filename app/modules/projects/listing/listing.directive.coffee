ProjectsListingDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        itemEl = null
        tdom = el.find(".js-sortable")

        tdom.sortable({
            dropOnEmpty: true
            revert: 200
            axis: "y"
        })

        tdom.on "sortstop", (event, ui) ->
            itemEl = ui.item
            project = itemEl.scope().project
            index = itemEl.index()
            scope.sorted_project_ids = _.without(scope.sorted_project_ids, project.id)
            scope.sorted_project_ids.splice(index, 0, project.id)
            sortData = []
            for value, index in scope.sorted_project_ids
                sortData.push({"project_id": value, "order":index})

            projectsService.bulkUpdateProjectsOrder(sortData)

        projectsService.projectsSuscription (projects) ->
            scope.vm.projects = projects
            scope.sorted_project_ids = _.map(projects.all, (p) -> p.id)

        projectsService.getProjects(true)

        """
        projectsService.fetchProjects().then (projects) ->
            Object.defineProperty scope.vm, "projects", {
                get: () ->
                    projects = projectsService.getProjects()
                    if projects
                        scope.sorted_project_ids = _.map(projects.all, (p) -> p.id)
                    return projects
            }
        """
    directive = {
        templateUrl: "projects/listing/listing.html"
        scope: {}
        link: link
    }

    return directive

angular.module("taigaProjects").directive("tgProjectsListing",
    ["tgProjects", ProjectsListingDirective])
