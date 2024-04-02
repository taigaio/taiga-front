###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class IssuesTableController
    edit: (issue) ->
        @.onEditIssue({id: issue.id})

    toggleTags: () ->
        @.onToggleTags({tags: @.showTags})

    detach: (issue) ->
        @.onDetachIssue({id: issue.id})

    delete: (issue) ->
        @.onDeleteIssue({id: issue.id})

angular.module('taigaComponents').controller('IssuesTable', IssuesTableController)
