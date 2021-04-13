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
