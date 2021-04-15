###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
