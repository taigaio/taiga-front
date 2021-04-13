module = angular.module("taigaHistory")

class ActivitiesDiffController
    @.$inject = [
    ]

    constructor: () ->

    diffTags: () ->
        if @.type == 'tags'
            @.diffRemoveTags = _.difference(@.diff[0], @.diff[1]).toString()
            @.diffAddTags = _.difference(@.diff[1], @.diff[0]).toString()
        else if @.type == 'promoted_to'
            diff = _.difference(@.diff[1], @.diff[0])
            @.promotedTo = _.filter(@.model.generated_user_stories, (x) => _.includes(diff, x.id))

module.controller("ActivitiesDiffCtrl", ActivitiesDiffController)
