###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: user-timeline-item-title.service.coffee
###

unslugify = @.taiga.unslugify

class UserTimelineItemTitle
    @.$inject = [
        "$translate",
        "$sce"
    ]

    _fieldTranslationKey: {
        'status': 'COMMON.FIELDS.STATUS',
        'subject': 'COMMON.FIELDS.SUBJECT',
        'description_diff': 'COMMON.FIELDS.DESCRIPTION',
        'points': 'COMMON.FIELDS.POINTS',
        'assigned_to': 'COMMON.FIELDS.ASSIGNED_TO',
        'assigned_users': 'COMMON.FIELDS.ASSIGNED_USERS',
        'severity': 'ISSUES.FIELDS.SEVERITY',
        'priority': 'ISSUES.FIELDS.PRIORITY',
        'type': 'ISSUES.FIELDS.TYPE',
        'is_iocaine': 'TASK.FIELDS.IS_IOCAINE',
        'is_blocked': 'COMMON.FIELDS.IS_BLOCKED',
        'color': 'COMMON.FIELDS.COLOR',
        'due_date': 'COMMON.FIELDS.DUE_DATE',
        'due_date_reason': 'COMMON.FIELDS.DUE_DATE_REASON',
        'milestone': 'COMMON.FIELDS.SPRINT',
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

                # assigned_users to unasigned
                if value == null && timeline.getIn(["data", "value_diff", "key"]) == 'assigned_users'
                    value = @translate.instant('ACTIVITY.VALUES.UNASSIGNED')

                # due date
                else if timeline.getIn(["data", "value_diff", "key"]) == 'due_date'
                    if value
                        prettyDate = @translate.instant("COMMON.PICKERDATE.FORMAT")
                        value = moment(value, "YYYY-MM-DD").format(prettyDate)
                    else
                        value = @translate.instant('ACTIVITY.VALUES.NOT_SET')

                new_value = value
            else
                new_value = timeline.getIn(["data", "value_diff", "value"]).first().get(1)

            return _.escape(new_value)

        sprint_name: (timeline, event) ->
            url = "project-taskboard:project=timeline.getIn(['data', 'project', 'slug']),sprint=timeline.getIn(['data', 'milestone', 'slug'])"

            return @._getLink(url, timeline.getIn(['data', 'milestone', 'name']))

        us_name: (timeline, event) ->
            obj = @._getTimelineObj(timeline, event).get('userstory')

            event_us = {obj: 'parent_userstory'}
            url = @._getDetailObjUrl(event_us)

            text = '#' + obj.get('ref') + ' ' + obj.get('subject')

            return @._getLink(url, text)

        related_us_name: (timeline, event) ->
            obj = timeline.getIn(["data", "userstory"])
            url = "project-userstories-detail:project=timeline.getIn(['data', 'userstory', 'project', 'slug']),ref=timeline.getIn(['data', 'userstory', 'ref'])"
            text = '#' + obj.get('ref') + ' ' + obj.get('subject')
            return @._getLink(url, text)

        epic_name: (timeline, event) ->
            obj = timeline.getIn(["data", "epic"])
            url = "project-epics-detail:project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['data', 'epic', 'ref'])"
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
            return _.escape(timeline.getIn(['data', 'value_diff', 'value']).keySeq().first())
    }

    constructor: (@translate, @sce) ->


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
            "milestone": ["project-taskboard", ":project=timeline.getIn(['data', 'project', 'slug']),sprint=timeline.getIn(['obj', 'slug'])"],
            "epic": ["project-epics-detail", ":project=timeline.getIn(['data', 'project', 'slug']),ref=timeline.getIn(['obj', 'ref'])"]
        }
        return url[event.obj][0] + url[event.obj][1]

    _getLink: (url, text, title) ->
        title = title || text

        span = $('<span>')
            .attr('ng-non-bindable', true)
            .text(text)

        return $('<a>')
            .attr('tg-nav', url)
            .attr('title', title)
            .append(span)
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
        params = @._getParams(timeline, event, type)
        # console.log(timeline)
        # console.log(event)
        paramsKeys = {}
        Object.keys(params).forEach (key) -> paramsKeys[key] = '{{' +key + '}}'

        translation = @translate.instant(type.key, paramsKeys)

        Object.keys(params).forEach (key) ->
            find = '{{' +key + '}}'
            translation = translation.replace(new RegExp(find, 'g'), params[key])

        return translation

angular.module("taigaUserTimeline")
    .service("tgUserTimelineItemTitle", UserTimelineItemTitle)
