timelineType = (timeline, event) ->
    types = [
        { # NewMember
            check: (timeline, event) ->
                return event.obj == 'membership'
            key: 'TIMELINE.NEW_MEMBER',
            translate_params: ['project_name']
            member: (timeline) ->
                return {
                    user: timeline.data.user,
                    role: timeline.data.role
                }
        },
        { # NewProject
            check: (timeline, event) ->
                return event.obj == 'project' && event.type == 'create'
            key: 'TIMELINE.NEW_PROJECT',
            translate_params: ['username', 'project_name'],
            description: (timeline) ->
                return timeline.data.project.description
        },
        { # NewAttachment
            check: (timeline, event) ->
                return event.type == 'change' && timeline.data.values_diff.attachments
            key: 'TIMELINE.UPLOAD_ATTACHMENT',
            translate_params: ['username', 'obj_name']
        },
        { # NewUs
            check: (timeline, event) ->
                return event.obj == 'userstory' && event.type == 'create'
            key: 'TIMELINE.US_CREATED',
            translate_params: ['username', 'project_name', 'obj_name']
        },
        { # NewIssue
            check: (timeline, event) ->
                return event.obj == 'issue' && event.type == 'create'
            key: 'TIMELINE.ISSUE_CREATED',
            translate_params: ['username', 'project_name', 'obj_name']
        },
        { # NewWiki
            check: (timeline, event) ->
                return event.obj == 'wikipage' && event.type == 'create'
            key: 'TIMELINE.WIKI_CREATED',
            translate_params: ['username', 'project_name', 'obj_name']
        },
        { # NewTask
            check: (timeline, event) ->
                return event.obj == 'task' && event.type == 'create'
            key: 'TIMELINE.TASK_CREATED',
            translate_params: ['username', 'project_name', 'obj_name']
        },
        { # NewUsComment
            check: (timeline, event) ->
                return timeline.data.comment && event.obj == 'userstory'
            key: 'TIMELINE.NEW_COMMENT_US',
            translate_params: ['username', 'obj_name'],
            description: (timeline) ->
                return taiga.stripTags(timeline.data.comment_html, 'br|p')
        },
        { # NewIssueComment
            check: (timeline, event) ->
                return timeline.data.comment && event.obj == 'issue'
            key: 'TIMELINE.NEW_COMMENT_ISSUE',
            translate_params: ['username', 'obj_name'],
            description: (timeline) ->
                text = taiga.replaceTags(timeline.data.comment_html, 'h1|h2|h3', 'p')
                return taiga.stripTags(text, 'br|p')
        },
        { # NewTask
            check: (timeline, event) ->
                return timeline.data.comment && event.obj == 'task'
            key: 'TIMELINE.NEW_COMMENT_TASK'
            translate_params: ['username', 'obj_name'],
            description: (timeline) ->
                return taiga.stripTags(timeline.data.comment_html, 'br|p')
        },
        { # UsToMilestone
            check: (timeline, event, field_name) ->
                if field_name == 'milestone' && event.type == 'change'
                    return timeline.data.values_diff.milestone[0] == null

                return false
            key: 'TIMELINE.US_ADDED_MILESTONE',
            translate_params: ['username', 'obj_name', 'sprint_name']
        },
        { # UsToBacklog
            check: (timeline, event, field_name) ->
                if field_name == 'milestone' && event.type == 'change'
                    return timeline.data.values_diff.milestone[1] == null

                return false
            key: 'TIMELINE.US_REMOVED_FROM_MILESTONE',
            translate_params: ['username', 'obj_name']
        },
        { # Blocked
            check: (timeline, event) ->
                if event.type == 'change' && timeline.data.values_diff.is_blocked
                    return timeline.data.values_diff.is_blocked[1] == true

                return false
            key: 'TIMELINE.BLOCKED',
            translate_params: ['username', 'obj_name'],
            description: (timeline) ->
                return taiga.stripTags(timeline.data.values_diff.blocked_note_html[1], 'br')
        },
        { # UnBlocked
            check: (timeline, event) ->
                if event.type == 'change' && timeline.data.values_diff.is_blocked
                    return timeline.data.values_diff.is_blocked[1] == false

                return false
            key: 'TIMELINE.UNBLOCKED',
            translate_params: ['username', 'obj_name']
        },
        { # MilestoneUpdated
            check: (timeline, event) ->
                return event.obj == 'milestone' && event.type == 'change'
            key: 'TIMELINE.MILESTONE_UPDATED',
            translate_params: ['username', 'obj_name']
        },
        { # WikiUpdated
            check: (timeline, event) ->
                return event.obj == 'wikipage' && event.type == 'change'
            key: 'TIMELINE.WIKI_UPDATED',
            translate_params: ['username', 'obj_name']
        },
        { # UsUpdated
            check: (timeline, event) ->
                return event.obj == 'userstory' && event.type == 'change'
            key: 'TIMELINE.US_UPDATED',
            translate_params: ['username', 'field_name', 'obj_name']
        },
        { # IssueUpdated
            check: (timeline, event) ->
                return event.obj == 'issue' && event.type == 'change'
            key: 'TIMELINE.ISSUE_UPDATED',
            translate_params: ['username', 'field_name', 'obj_name']
        },
        { # TaskUpdated
            check: (timeline, event) ->
                return event.obj == 'task' && event.type == 'change'
            key: 'TIMELINE.TASK_UPDATED',
            translate_params: ['username', 'field_name', 'obj_name']
        }
    ]

    if timeline.data.values_diff
        field_name = Object.keys(timeline.data.values_diff)[0]

    return _.find types, (obj) ->
        return obj.check(timeline, event, field_name)

TimelineItemDirective = ($tgTemplate, $compile, $navUrls, $translate, $sce) ->
    fieldTranslationKey = {
        'status': 'COMMON.FIELDS.STATUS',
        'subject': 'COMMON.FIELDS.SUBJECT',
        'description': 'COMMON.FIELDS.DESCRIPTION',
        'points': 'COMMON.FIELDS.POINTS',
        'severity': 'ISSUES.FIELDS.SEVERITY',
        'priority': 'ISSUES.FIELDS.PRIORITY',
        'type': 'ISSUES.FIELDS.TYPE',
        'is_iocaine': 'TASK.FIELDS.IS_IOCAINE'
    }

    parseEventType = (event_type) ->
        event_type = event_type.split(".")

        return {
            section: event_type[0],
            obj: event_type[1],
            type: event_type[2]
        }

    getDetailObjUrl = (event) ->
        url = {
            "issue": ["project-issues-detail", ":project=activity.project.slug,ref=activity.obj.ref"],
            "wikipage": ["project-wiki-page", ":project=activity.project.slug,slug=activity.obj.slug"],
            "task": ["project-tasks-detail", ":project=activity.project.slug,ref=activity.obj.ref"],
            "userstory": ["project-userstories-detail", ":project=activity.project.slug,ref=activity.obj.ref"],
            "milestone": ["project-taskboard", ":project=activity.project.slug,sprint=activity.obj.slug"]
        }

        return url[event.obj][0] + url[event.obj][1]

    getLink = (url, text, title) ->
        title = title || text

        return $('<a>')
            .attr('tg-nav', url)
            .text(text)
            .attr('title', title)
            .prop('outerHTML')

    translate_params = {
        username: (timeline) ->
            user = timeline.data.user
            title_attr = $translate.instant('COMMON.SEE_USER_PROFILE', {username: user.username})
            url = 'user-profile:username=activity.user.username'
            return getLink(url, user.username, title_attr)

        field_name: (timeline) ->
            field_name = Object.keys(timeline.data.values_diff)[0]

            return $translate.instant(fieldTranslationKey[field_name])

        project_name: (timeline) ->
            url = 'project:project=activity.project.slug'

            return getLink(url, timeline.data.project.name)

        sprint_name: (timeline) ->
            url = 'project-taskboard:project=activity.project.slug,sprint=activity.sprint.slug'

            return getLink(url, timeline.data.milestone.name)

        obj_name: (timeline, event) ->
            obj = getTimelineObj(timeline, event)
            url = getDetailObjUrl(event)

            if event.obj == 'wikipage'
                text = obj.slug
            else if event.obj == 'milestone'
                text = obj.name
            else
                text = '#' + obj.ref + ' ' + obj.subject

            return getLink(url, text)
    }

    getTimelineObj = (timeline, event) ->
        return timeline.data[event.obj]

    getParams = (timeline, event, timeline_type) ->
        params = {}

        timeline_type.translate_params.forEach (param) ->
            params[param] = translate_params[param](timeline, event)

        return params

    getTitle = (timeline, event, type) ->
        return $translate.instant(type.key, getParams(timeline, event, type))

    link = ($scope, $el, $attrs) ->
        event = parseEventType($scope.timeline.event_type)
        type = timelineType($scope.timeline, event)

        $scope.activity = {}

        $scope.activity.obj = getTimelineObj($scope.timeline, event)
        $scope.activity.user = $scope.timeline.data.user
        $scope.activity.project = $scope.timeline.data.project
        $scope.activity.sprint = $scope.timeline.data.milestone
        $scope.activity.title = getTitle($scope.timeline, event, type)
        $scope.activity.created_formated = moment($scope.timeline.created).fromNow()

        if type.description
            $scope.activity.description = $sce.trustAsHtml(type.description($scope.timeline))

        if type.member
            $scope.activity.member = type.member($scope.timeline)

        if $scope.timeline.data.values_diff?.attachments
            $scope.activity.attachments = $scope.timeline.data.values_diff.attachments.new

    return {
        link: link
        templateUrl: "profile/timeline/timeline-item.html"
        scope: {
            timeline: "=tgTimelineItem"
        }
    }

angular.module("taigaProfile")
    .directive("tgTimelineItem", ["$tgTemplate", "$compile", "$tgNavUrls", "$translate", "$sce", TimelineItemDirective])
