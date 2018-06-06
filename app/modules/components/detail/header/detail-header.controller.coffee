###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: story-header.controller.coffee
###

module = angular.module("taigaUserStories")

class StoryHeaderController
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

    _checkNav: () ->
        if @.item.neighbors.previous?.ref?
            ctx = {
                project: @.project.slug
                ref: @.item.neighbors.previous.ref
            }
            @.previousUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

        if @.item.neighbors.next?.ref?
            ctx = {
                project: @.project.slug
                ref: @.item.neighbors.next.ref
            }
            @.nextUrl = @navUrls.resolve("project-" + @.item._name + "-detail", ctx)

    _checkPermissions: () ->
        @.permissions = {
            canEdit: _.includes(@.project.my_permissions, @.requiredPerm)
        }

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

module.controller("StoryHeaderCtrl", StoryHeaderController)
