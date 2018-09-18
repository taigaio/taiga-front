###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: modules/backlog/sprints.coffee
###

taiga = @.taiga

module = angular.module("taigaBacklog")


#############################################################################
## Sprint Actions Directive
#############################################################################

BacklogSprintDirective = ($repo, $rootscope) ->
    sprintTableMinHeight = 50
    slideOptions = {
        duration: 500,
        easing: 'linear'
    }

    toggleSprint = ($el) =>
        sprintTable = $el.find(".sprint-table")
        sprintArrow = $el.find(".compact-sprint")

        sprintArrow.toggleClass('active')
        sprintTable.toggleClass('open')

    link = ($scope, $el, $attrs) ->
        $scope.$watch $attrs.tgBacklogSprint, (sprint) ->
            sprint = $scope.$eval($attrs.tgBacklogSprint)

            if sprint.closed
                $el.addClass("sprint-closed")
            else
                toggleSprint($el)

        # Event Handlers
        $el.on "click", ".sprint-name > .compact-sprint", (event) ->
            event.preventDefault()

            toggleSprint($el)

            $el.find(".sprint-table").slideToggle(slideOptions)

        $el.on "click", ".edit-sprint", (event) ->
            event.preventDefault()

            sprint = $scope.$eval($attrs.tgBacklogSprint)
            $rootscope.$broadcast("sprintform:edit", sprint)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogSprint", ["$tgRepo", "$rootScope", BacklogSprintDirective])


#############################################################################
## Sprint Header Directive
#############################################################################

BacklogSprintHeaderDirective = ($navUrls, $template, $compile, $translate) ->
    template = $template.get("backlog/sprint-header.html")

    link = ($scope, $el, $attrs, $model) ->
        prettyDate = $translate.instant("BACKLOG.SPRINTS.DATE")

        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_milestone") != -1

        isVisible = ->
            return $scope.project.my_permissions.indexOf("view_milestones") != -1

        render = (sprint) ->
            taskboardUrl = $navUrls.resolve("project-taskboard",
                                            {project: $scope.project.slug, sprint: sprint.slug})

            start = moment(sprint.estimated_start).format(prettyDate)
            finish = moment(sprint.estimated_finish).format(prettyDate)

            estimatedDateRange = "#{start}-#{finish}"

            ctx = {
                name: sprint.name
                taskboardUrl: taskboardUrl
                estimatedDateRange: estimatedDateRange
                closedPoints: sprint.closed_points or 0
                totalPoints: sprint.total_points or 0
                isVisible: isVisible()
                isEditable: isEditable()
            }

            templateScope = $scope.$new()

            _.assign(templateScope, ctx)

            compiledTemplate = $compile(template)(templateScope)
            $el.html(compiledTemplate)

        $scope.$watch "sprint", (sprint) ->
            render(sprint)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
    }

module.directive("tgBacklogSprintHeader", ["$tgNavUrls", "$tgTemplate", "$compile", "$translate"
                                           BacklogSprintHeaderDirective])


#############################################################################
## Toggle Closed Sprints Directive
#############################################################################

ToggleExcludeClosedSprintsVisualization = ($rootscope, $loading, $translate) ->
    excludeClosedSprints = true

    link = ($scope, $el, $attrs) ->
        # insert loading wrapper
        loadingElm = $("<div>")
        $el.after(loadingElm)

        currentLoading = null

        # Event Handlers
        $el.on "click", (event) ->
            event.preventDefault()
            excludeClosedSprints  = not excludeClosedSprints

            currentLoading = $loading()
                .target(loadingElm)
                .start()

            if excludeClosedSprints
                $rootscope.$broadcast("backlog:unload-closed-sprints")
            else
                $rootscope.$broadcast("backlog:load-closed-sprints")

        $scope.$on "$destroy", ->
            $el.off()

        $scope.$on "closed-sprints:reloaded", (ctx, sprints) =>
            currentLoading.finish()

            if sprints.length > 0
                key = "BACKLOG.SPRINTS.ACTION_HIDE_CLOSED_SPRINTS"
            else
                key = "BACKLOG.SPRINTS.ACTION_SHOW_CLOSED_SPRINTS"

            text = $translate.instant(key)

            $el.find(".text").text(text)

    return {link: link}

module.directive("tgBacklogToggleClosedSprintsVisualization", ["$rootScope", "$tgLoading", "$translate",
                                                               ToggleExcludeClosedSprintsVisualization])
