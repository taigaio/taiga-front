TimelineItemDirective = ($tgTemplate, $compile, $navUrls) ->
    parseEventType = (event_type) ->
        event_type = event_type.split(".")

        return {
            section: event_type[0],
            obj: event_type[1],
            type: event_type[2]
        }

    getUrl = (timeline, event) ->
        url = {
            "issue": "project-issues-detail",
            "wiki": "project-wiki-page",
            "task": "project-tasks-detail",
            "userstories": "project-userstories-detail"
        }

        params = {project: timeline.data.project.slug, ref: timeline.data[event.obj].ref}

        return $navUrls.resolve(url[event.obj], params)

    getTemplate = (timeline, event) ->
        template = ""

        if event.type == 'change'
            if timeline.data.comment.length
                 template = "profile/timeline/comment-timeline.html"
            else if timeline.data.values_diff.attachments
                 template = "profile/timeline/attachment-timeline.html"

        return $tgTemplate.get(template)

    link = ($scope, $el, $attrs) ->
        event = parseEventType($scope.timeline.event_type)
        template = getTemplate($scope.timeline, event)

        if !template
            return ""

        obj = $scope.timeline.data[event.obj]

        $scope.timeline.subject = obj.subject
        $scope.timeline.ref = obj.ref
        $scope.timeline.type = event.obj
        $scope.timeline.created_formated = moment($scope.timeline.created).fromNow()
        $scope.timeline.detail_url = getUrl($scope.timeline, event)

        $el.html(template)
        $compile($el.contents())($scope)

    return {
        link: link
        scope: {
            timeline: "=tgTimelineItem"
        }
    }

angular.module("taigaProfile")
    .directive("tgTimelineItem", ["$tgTemplate", "$compile", "$tgNavUrls", TimelineItemDirective])
