###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
            onToggleTags: '&'
        },
        scope: true,
        link: link
    }

module.directive('tgIssuesTable', ['$timeout', issuesTableDirective])
