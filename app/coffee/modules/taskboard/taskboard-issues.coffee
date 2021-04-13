groupBy = @.taiga.groupBy

class TaskboardIssuesService extends taiga.Service
    @.$inject = []
    constructor: () ->
        @.reset()

    reset: () ->
        @.foldStatusChanged = {}
        @.issuesRaw = []

    init: (project, usersById, issueStatusById) ->
        @.issueStatusById = issueStatusById
        @.project = project
        @.usersById = usersById

    resetFolds: () ->
        @.foldStatusChanged = {}
        @.refresh()

    toggleFold: (issueId) ->
        @.foldStatusChanged[issueId] = !@.foldStatusChanged[issueId]
        @.refresh()

    add: (issue) ->
        @.issuesRaw = @.issuesRaw.concat(issue)
        @.refresh()

    remove: (issue) ->
        for key, item of @.issuesRaw
            if issue.id == item.id
                @.issuesRaw.splice(key, 1)
                @.refresh()
                return

    set: (issues) ->
        @.issuesRaw = issues
        @.refresh()

    getIssue: (id) ->
        return @.milestoneIssues.find (issue) -> return issue.get('id') == id

    getIssueModel: (id) ->
        return _.find @.issuesRaw, (issue) -> return issue.id == id

    replaceModel: (issue) ->
        @.issuesRaw = _.map @.issuesRaw, (item) ->
            if issue.id == item.id
                return issue
            else
                return item

        @.refresh()

    refresh: ->
        issues = []
        for issueModel in @.issuesRaw
            issue = {}
            issue.foldStatusChanged = @.foldStatusChanged[issueModel.id]
            issue.model = issueModel.getAttrs()
            issue.modelName = issueModel.getName()
            issue.id = issueModel.id
            issue.status = @.issueStatusById[issueModel.status]
            issue.images = _.filter issue.model.attachments, (it) -> return !!it.thumbnail_card_url
            issue.assigned_to = @.usersById[issueModel.assigned_to]
            issue.colorized_tags = _.map issue.model.tags, (tag) ->
                return {name: tag[0], color: tag[1]}

            issues.push(issue)

        @.milestoneIssues = Immutable.fromJS(issues)

angular.module("taigaKanban").service("tgTaskboardIssues", TaskboardIssuesService)
