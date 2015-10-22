unslugify = @.taiga.unslugify

class UserTimelineItemTitle
    @.$inject = [
        "$translate"
    ]

    _fieldTranslationKey: {
        'status': 'COMMON.FIELDS.STATUS',
        'subject': 'COMMON.FIELDS.SUBJECT',
        'description_diff': 'COMMON.FIELDS.DESCRIPTION',
        'points': 'COMMON.FIELDS.POINTS',
        'assigned_to': 'COMMON.FIELDS.ASSIGNED_TO',
        'severity': 'ISSUES.FIELDS.SEVERITY',
        'priority': 'ISSUES.FIELDS.PRIORITY',
        'type': 'ISSUES.FIELDS.TYPE',
        'is_iocaine': 'TASK.FIELDS.IS_IOCAINE',
        'is_blocked': 'COMMON.FIELDS.IS_BLOCKED'
    }

    _params: {
        username: (timeline, event) ->
            user = timeline.getIn(['data', 'user'])

            if user.get('is_profile_visible')
                title_attr = @translate.instant('COMMON.SEE_USER_PROFILE', {username: user.get('username')})
                url = "user-profile:username=timeline.getIn(['data', 'user', 'username'])"

                return @._getLink(url, user.get('name'), title_attr)
            else
                return @._getUsernameSpan(user.get('name'))

        field_name: (timeline, event) ->
            field_name = timeline.getIn(['data', 'value_diff', 'key'])

            return @translate.instant(@._fieldTranslationKey[field_name])

        project_name: (timeline, event) ->
            url = "project:project=timeline.getIn(['data', 'project', 'slug'])"

            return @._getLink(url, timeline.getIn(["data", "project", "name"]))

        new_value: (timeline, event) ->
            if _.isArray(timeline.getIn(["data", "value_diff", "value"]).toJS())
                value = timeline.getIn(["data", "value_diff", "value"]).get(1)

                # assigned to unasigned
                if value == null && timeline.getIn(["data", "value_diff", "key"]) == 'assigned_to'
                    value = @translate.instant('ACTIVITY.VALUES.UNASSIGNED')

                return value
            else
                return timeline.getIn(["data", "value_diff", "value"]).first().get(1)

        sprint_name: (timeline, event) ->
            url = "project-taskboard:project=timeline.getIn(['data', 'project', 'slug']),sprint=timeline.getIn(['data', 'milestone', 'slug'])"

            return @._getLink(url, timeline.getIn(['data', 'milestone', 'name']))

        us_name: (timeline, event) ->
            obj = @._getTimelineObj(timeline, event).get('userstory')

            event_us = {obj: 'parent_userstory'}
            url = @._getDetailObjUrl(event_us)

            text = '#' + obj.get('ref') + ' ' + obj.get('subject')

            return @._getLink(url, text)

        obj_name: (timeline, event) ->
            obj = @._getTimelineObj(timeline, event)
            url = @._getDetailObjUrl(event)

            if event.obj == 'wikipage'
                text = unslugify(obj.get('slug'))
            else if event.obj == 'milestone'
                text = obj.get('name')
            else
                text = '#' + obj.get('ref') + ' ' + obj.get('subject')

            return @._getLink(url, text)

        role_name: (timeline, event) ->
            return timeline.getIn(['data', 'value_diff', 'value']).keySeq().first()
    }

    constructor: (@translate) ->


    _translateTitleParams: (param, timeline, event) ->
        return @._params[param].call(this, timeline, event)

    _getTimelineObj: (timeline, event) ->
        return timeline.getIn(['data', event.obj])

    _getDetailObjUrl: (event) ->
        url = {
            "issue": ["project-issues-detail", ":project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['obj', 'ref'])"],
            "wikipage": ["project-wiki-page", ":project=timeline.getIn(['data', 'project', 'slug']),slug=timeline.getIn(['obj', 'slug'])"],
            "task": ["project-tasks-detail", ":project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['obj', 'ref'])"],
            "userstory": ["project-userstories-detail", ":project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['obj', 'ref'])"],
            "parent_userstory": ["project-userstories-detail", ":project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['obj', 'userstory', 'ref'])"],
            "milestone": ["project-taskboard", ":project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['obj', 'ref'])"]
        }

        return url[event.obj][0] + url[event.obj][1]

    _getLink: (url, text, title) ->
        title = title || text

        return $('<a>')
            .attr('tg-nav', url)
            .text(text)
            .attr('title', title)
            .prop('outerHTML')

    _getUsernameSpan: (text) ->
        title = title || text

        return $('<span>')
            .addClass('username')
            .text(text)
            .prop('outerHTML')

    _getParams: (timeline, event, timeline_type) ->
        params = {}

        timeline_type.translate_params.forEach (param) =>
            params[param] = @._translateTitleParams(param, timeline, event)

        return params

    getTitle: (timeline, event, type) ->
        return @translate.instant(type.key, @._getParams(timeline, event, type))

angular.module("taigaUserTimeline")
    .service("tgUserTimelineItemTitle", UserTimelineItemTitle)
