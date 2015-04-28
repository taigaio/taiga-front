ProjectsListingDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}
        itemEl = null
        tdom = el.find(".js-sortable")

        tdom.sortable({
            dropOnEmpty: true
            revert: 200
            axis: "y"
            opacity: .95
            placeholder: 'placeholder'
        })

        tdom.on "sortstop", (event, ui) ->
            itemEl = ui.item
            project = itemEl.scope().project
            index = itemEl.index()

            sorted_project_ids = _.map(scope.vm.projects.toArray(), (p) -> p.id)
            sorted_project_ids = _.without(sorted_project_ids, project.id)
            sorted_project_ids.splice(index, 0, project.id)
            sortData = []
            for value, index in sorted_project_ids
                sortData.push({"project_id": value, "order":index})

            projectsService.bulkUpdateProjectsOrder(sortData)

        taiga.defineImmutableProperty(scope.vm, "projects", () -> projectsService.projects.get("all"))

        scope.vm.newProject = ->
            projectsService.newProject()

    directive = {
        templateUrl: "projects/listing/projects-listing.html"
        scope: {}
        link: link
    }

    return directive

angular.module("taigaProjects").directive("tgProjectsListing", ["tgProjectsService", ProjectsListingDirective])
