describe "Kanban template", ->
    $templateCache = null

    beforeEach ->
        module "templates"

        inject (_$templateCache_) ->
            $templateCache = _$templateCache_

    it "wires move to top for cards with and without swimlanes", ->
        template = $($templateCache.get("kanban/kanban.html"))
        swimlanes = template.find('.kanban-swimlane[ng-if="swimlanesList.size"]')
        noSwimlanes = template.find('.kanban-table-body[ng-if="!swimlanesList.size"]')
        expectedCallback = "ctrl.moveToTopDropdown(usMap.get(usId))"

        expect(swimlanes.find("tg-card")).to.have.attr(
            "on-click-move-to-top",
            expectedCallback
        )
        expect(noSwimlanes.find("tg-card")).to.have.attr(
            "on-click-move-to-top",
            expectedCallback
        )

        expect(swimlanes.find("tg-card")).to.have.attr("is-first", "$first")
        expect(noSwimlanes.find("tg-card")).to.have.attr("is-first", "$first")
