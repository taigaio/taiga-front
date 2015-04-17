ProjectsListingDirective = ($rs) ->
    link = (scope, el, attrs, ctrl) ->
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

            $rs.projects.bulkUpdateOrder(sortData)

        scope.$watch "vm.projects", (projects) =>
            if projects?
                scope.sorted_project_ids = _.map(projects.all, (p) -> p.id)

    directive = {
        templateUrl: "projects/listing/listing.html"
        controller: "ProjectsController"
        scope: {}
        bindToController: true
        controllerAs: "vm"
        link: link
    }

    return directive

angular.module("taigaProjects").directive("tgProjectsListing",
    ["$tgResources", ProjectsListingDirective])
