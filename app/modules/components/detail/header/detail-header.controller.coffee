###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaBase')

class DetailHeaderController
    @.$inject = [
        "$rootScope",
        "$tgConfirm",
        "$tgQueueModelTransformation",
        "$tgNavUrls",
        "$window"
    ]

    constructor: (@rootScope, @confirm, @modelTransform, @navUrls, @window) ->
        @.editMode = false
        @.loadingSubject = false
        @.originalSubject = @.item.subject
        @.objType = {
            'tasks': 'task',
            'issues': 'issue',
            'userstories': 'us',
        }[@.item._name]

    _checkPermissions: () ->
        @.permissions = {
            canEdit: _.includes(@.project.my_permissions, @.requiredPerm)
        }

    cancelEdit: () ->
        @.editMode = false
        @.item.subject = @.originalSubject

    editSubject: (value) ->
        selection = @window.getSelection()
        if selection.type != "Range"
            if value
                @.editMode = true
            if !value
                @.editMode = false

    onKeyDown: (event) ->
        if event.which == 13
            @.saveSubject()

        if event.which == 27
            @.item.subject = @.originalSubject
            @.editSubject(false)

    saveSubject: () ->
        onEditSubjectSuccess = () =>
            @.loadingSubject = false
            @rootScope.$broadcast("object:updated")
            @confirm.notify('success')
            @.originalSubject = @.item.subject

        onEditSubjectError = () =>
            @.loadingSubject = false
            @confirm.notify('error')

        @.editMode = false
        @.loadingSubject = true
        item = @.item
        transform = @modelTransform.save (item) ->
            return item
        return transform.then(onEditSubjectSuccess, onEditSubjectError)

module.controller("DetailHeaderCtrl", DetailHeaderController)
