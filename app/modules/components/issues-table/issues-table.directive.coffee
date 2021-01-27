###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: components/issues/issues.directive.coffee
###

module = angular.module("taigaComponents")

issuesTableDirective = ($timeout) ->

    link = (scope, el, attrs, ctrl) ->
        scope.issueOptions = null

        scope.displayOptions = (id) ->
            if (timeout)
                $timeout.cancel(timeout)
                timeout = null
            scope.issueOptions = id

        scope.hideOptions = () ->
            timeout = $timeout (() ->
                scope.issueOptions = null
            ), 200

    return {
        controller: "IssuesTable",
        controllerAs: "ctrl",
        templateUrl: "components/issues-table/issues-table.html",
        bindToController: {
            issues: "<",
            showTags: "=",
            onLoadIssues: '&',
            onAddIssuesInBulk: '&',
            onAddNewIssue: '&',
            sprintIssues: '<',
            onDeleteIssue: '&',
            onEditIssue: '&',
            onDetachIssue: '&',
        },
        scope: true,
        link: link
    }

module.directive('tgIssuesTable', ['$timeout', issuesTableDirective])
