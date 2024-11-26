###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

        $scope.$on "closed-sprints:reloaded", (ctx, sprints) ->
            if currentLoading
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

SprintDirective = (avatarService) ->
    return {
        templateUrl: 'backlog/sprint.html'
        scope: {
            sprint: '=',
            project: '=',
        }
    }

SprintDirective.$inject = []

module.directive("tgSprint", SprintDirective)
