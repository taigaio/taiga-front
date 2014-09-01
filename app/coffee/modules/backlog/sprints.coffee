###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy

module = angular.module("taigaBacklog")

#############################################################################
## Sprint Directive
#############################################################################

BacklogSprintDirective = ($repo, $rootscope) ->
    ## Common parts
    linkCommon = ($scope, $el, $attrs, $ctrl) ->
        sprint = $scope.$eval($attrs.tgBacklogSprint)
        if $scope.$first
            $el.addClass("sprint-current")
            $el.find(".sprint-table").addClass('open')

        else if sprint.closed
            $el.addClass("sprint-closed")

        else if not $scope.$first and not sprint.closed
            $el.addClass("sprint-old-open")

        # Update progress bars
        $scope.$watch $attrs.tgBacklogSprint, (value) ->
            sprint = $scope.$eval($attrs.tgBacklogSprint)

            if sprint.total_points
                progressPercentage = Math.round(100 * (sprint.closed_points / sprint.total_points))
            else
                progressPercentage = 0

            $el.find(".current-progress").css("width", "#{progressPercentage}%")

        $el.find(".sprint-table").disableSelection()

        # Event Handlers
        $el.on "click", ".sprint-name > .icon-arrow-up", (event) ->
            target = $(event.currentTarget)
            target.toggleClass('active')
            $el.find(".sprint-table").toggleClass('open')

        $el.on "click", ".sprint-name > .icon-edit", (event) ->
            $rootscope.$broadcast("sprintform:edit", sprint)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.closest("div.wrapper").controller()
        linkCommon($scope, $el, $attrs, $ctrl)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgBacklogSprint", ["$tgRepo", "$rootScope", BacklogSprintDirective])
