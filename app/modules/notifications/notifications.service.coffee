###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: user-notification/user-notification/user-notification.service.coffee
###

taiga = @.taiga

class NotificationsService extends taiga.Service
    @.$inject = [
        "tgResources"
        "tgUserTimelinePaginationSequenceService"
        "$translate"
        "$tgNavUrls"
        "$tgSections"
    ]

    _notificationTypes = [
        { # Assigned to you
            check: (notification) -> return notification.get('event_type') == 1
            key: 'EVENTS.ASSIGNED_YOU',
            translate_params: ['username', 'obj_name']
        },
        { # Mentioned you in a object description
            check: (notification) -> return notification.get('event_type') == 2
            key: 'EVENTS.MENTIONED_YOU',
            translate_params: ['username', 'obj_name'],
        },
        { # Added you as watcher
            check: (notification) -> return notification.get('event_type') == 3
            key: 'EVENTS.ADDED_YOU_AS_WATCHER',
            translate_params: ['username', 'obj_name'],
        },
        { # Added you as member
            check: (notification) -> return notification.get('event_type') == 4
            key: 'EVENTS.ADDED_YOU_AS_MEMBER',
            translate_params: ['username']
        },
        { # Commented
            check: (notification) -> return notification.get('event_type') == 5
            key: 'EVENTS.COMMENTED',
            translate_params: ['username', 'obj_name'],
        },
        { # Mentioned you in a comment
            check: (notification) -> return notification.get('event_type') == 6
            key: 'EVENTS.MENTIONED_YOU_IN_COMMENT',
            translate_params: ['username', 'obj_name'],
        },
    ]

    _params = {
        username: (notification) ->
            user = notification.getIn(['data', 'user'])
            if user.get('is_profile_visible')
                title_attr = @translate.instant('COMMON.SEE_USER_PROFILE', {username: user.get('username')})
                url = @navUrls.resolve('user-profile', {
                    username: notification.getIn(['data', 'user', 'username'])
                })
                return @._getLink(notification, url, user.get('name'), 'user-link', title_attr)
            else
                return @._getUsernameSpan(user.get('name'))

        project_name: (notification) ->
            url = @navUrls.resolve('project', {
                project: notification.getIn(['data', 'project', 'slug'])
            })
            return @._getLink(notification, url, notification.getIn(["data", "project", "name"]), 'project-link')

        obj_name: (notification) ->
            obj = @._getNotificationObject(notification)
            url = @._getDetailObjUrl(notification, obj.get('content_type'))
            text = '#' + obj.get('ref') + ' ' + obj.get('subject')
            return @._getLink(notification, url, text, 'object-link' )
    }

    constructor: (
        @rs
        @userTimelinePaginationSequenceService
        @translate
        @navUrls
        @tgSections
    ) ->

    getNotificationsList: (userId, onlyUnread) ->
        total = 0
        config = {}
        config.fetch = (page) =>
            return @rs.users.getNotifications(userId, page, onlyUnread)
                .then (response) ->
                    return response

        config.map = (obj) => @._addNotificationAttributes(obj)
        return @userTimelinePaginationSequenceService.generate(config)

    setNotificationAsRead: (notificationId) ->
        return @rs.users.setNotificationAsRead(notificationId)

    setNotificationsAsRead: () ->
        return @rs.users.setNotificationsAsRead()

    _getNotificationObject: (notification) ->
        if notification.get('data').get('obj')
            return notification.get('data').get('obj')

    _getType: (notification) ->
        return _.find _notificationTypes, (obj) ->
            return obj.check(notification)

    _addNotificationAttributes: (notification) ->
        event_type = notification.get('event_type')
        
        type =  @._getType(notification)

        title = @._getTitle(notification, event_type, type)
        notification = notification.set('title_html', title)

        projectSlug = notification.getIn(['data', 'project', 'slug'])
        projectSectionPath = @tgSections.getPath(projectSlug)
        projectUrl = @navUrls.resolve("project-#{projectSectionPath}", { project: projectSlug })
        notification = notification.set('projectUrl', projectUrl)

        notification = notification.set('obj', @._getNotificationObject(notification))

        return notification

    _translateTitleParams: (param, notification, event) ->
        return _params[param].call(this, notification, event)

    _getDetailObjUrl: (notification, contentType) ->
        urlMapping = {
            "issue": "project-issues-detail",
            "task": "project-tasks-detail",
            "userstory": "project-userstories-detail",
        }
        url = @navUrls.resolve(urlMapping[contentType], {
            project: notification.getIn(['data', 'project', 'slug']),
            ref: notification.getIn(['data', 'obj', 'ref'])
        })

        return url

    _getLink: (notification, url, text, css, title) ->
        title = title || text

        span = $('<span>')
            .attr('ng-non-bindable', true)
            .text(text)

        return $('<a href="">')
            .attr('title', title)
            .attr('class', css)
            .attr('ng-click', "vm.setAsRead(notification, \"#{url}\")")
            .append(span)
            .prop('outerHTML')

    _getUsernameSpan: (text) ->
        title = title || text

        return $('<span>')
            .addClass('username')
            .text(text)
            .prop('outerHTML')

    _getParams: (notification, event_type, notification_type) ->
        params = {}

        notification_type.translate_params.forEach (param) =>
            params[param] = @._translateTitleParams(param, notification, event_type)
        return params

    _getTitle: (notification, event_type, notification_type) ->
        params = @._getParams(notification, event_type, notification_type)

        paramsKeys = {}
        Object.keys(params).forEach (key) -> paramsKeys[key] = '{{' +key + '}}'

        translation = @translate.instant(notification_type.key, paramsKeys)

        Object.keys(params).forEach (key) ->
            find = '{{' +key + '}}'
            translation = translation.replace(new RegExp(find, 'g'), params[key])

        return translation

angular.module("taigaNotifications").service("tgNotificationsService", NotificationsService)
