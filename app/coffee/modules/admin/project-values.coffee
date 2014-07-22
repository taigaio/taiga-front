###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/admin/project-profile.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
trim = @.taiga.trim
toString = @.taiga.toString
joinStr = @.taiga.joinStr
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaAdmin")

#############################################################################
## Project Values Controller
#############################################################################

class ProjectValuesController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$location"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location) ->
        @scope.project = {}

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

        @scope.$on("admin:project-values:us-status:move", @.moveUsStatus)

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            return project

    loadUsStatus: =>
        return @rs.userstories.listStatuses(@scope.projectId).then (usStatuses) =>
            @scope.usStatuses = usStatuses
            @scope.maxUsStatusOrder = _.max(usStatuses, "order").order

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then( => @q.all([
            @.loadProject(),
            @.loadUsStatus(),
        ]))

    moveUsStatus: (ctx, itemUsStatus, itemIndex) =>
        usStatuses = @scope.usStatuses
        r = usStatuses.indexOf(itemUsStatus)
        usStatuses.splice(r, 1)
        usStatuses.splice(itemIndex, 0, itemUsStatus)
        _.each usStatuses, (usStatus, index) ->
            usStatus.order = index

        @repo.saveAll(usStatuses)

module.controller("ProjectValuesController", ProjectValuesController)

#############################################################################
## Project US Values Directive
#############################################################################

ProjectUsStatusDirective = ($log, $repo, $confirm, $location) ->

    #########################
    ## Drag & Drop Link
    #########################

    linkDragAndDrop = ($scope, $el, $attrs) ->
        oldParentScope = null
        newParentScope = null
        itemEl = null
        tdom = $el.find(".sortable")

        deleteElement = (itemEl) ->
            # Completelly remove item and its scope from dom
            itemEl.scope().$destroy()
            itemEl.off()
            itemEl.remove()

        tdom.sortable({
            handle: ".project-values-row.visualization",
            dropOnEmpty: true
            connectWith: ".project-values-body"
            revert: 400
            axis: "y"
        })

        tdom.on "sortstop", (event, ui) ->
            parentEl = ui.item.parent()
            itemEl = ui.item
            itemUsStatus = itemEl.scope().status
            itemIndex = itemEl.index()
            $scope.$broadcast("admin:project-values:us-status:move", itemUsStatus, itemIndex)

        $scope.$on "$destroy", ->
            $el.off()

    #########################
    ## Status Link
    #########################

    linkStatus = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        initializeNewUs = ->
            $scope.newUs = {
                "name": ""
                "is_closed": false
            }

        initializeNewUs()
        submit = =>
            promise = $repo.save($scope.project)
            promise.then ->
                $confirm.notify("success")

            promise.then null, (data) ->
                console.log "FAIL"
                # TODO

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", "form a.button-green", (event) ->
            event.preventDefault()
            submit()

        $el.on "click", ".show-add-new", (event) ->
            event.preventDefault()
            $el.find(".new-us-status").css('display': 'flex')

        $el.on "click", ".add-new", (event) ->
            event.preventDefault()
            form = $el.find(".new-us-status").parents("form").checksley()
            return if not form.validate()

            $scope.newUs.project = $scope.project.id
            $scope.newUs.order = $scope.maxUsStatusOrder + 1
            promise = $repo.create("userstory-statuses", $scope.newUs)
            promise.then =>
                $ctrl.loadUsStatus()
                $el.find(".new-us-status").hide()
                initializeNewUs()

            promise.then null, (data) ->
                form.setErrors(data)

        $el.on "click", ".delete-new", (event) ->
            event.preventDefault()
            $el.find(".new-us-status").hide()
            initializeNewUs()

        $el.on "click", ".edit-us-status", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            row = target.parents(".project-values-row")
            row.hide()
            row.siblings(".edition").css("display": "flex")

        $el.on "click", ".save", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            form = target.parents("form").checksley()
            return if not form.validate()

            status = target.scope().status
            promise = $repo.save(status)
            promise.then =>
                row = target.parents(".project-values-row")
                row.hide()
                row.siblings(".visualization").css("display": "flex")

            promise.then null, (data) ->
                form.setErrors(data)

        $el.on "click", ".cancel", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            row = target.parents(".project-values-row")
            row.hide()
            row.siblings(".visualization").css("display": "flex")

        $el.on "click", ".delete-us-status", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            status = target.scope().status

            #TODO: i18n
            title = "Delete User Story status"
            subtitle = status.name
            $confirm.ask(title, subtitle).then =>
                $repo.remove(status).then =>
                    $ctrl.loadUsStatus()

    link = ($scope, $el, $attrs) ->
        linkDragAndDrop($scope, $el, $attrs)
        linkStatus($scope, $el, $attrs)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}


module.directive("tgProjectUsStatus", ["$log", "$tgRepo", "$tgConfirm", "$tgLocation", ProjectUsStatusDirective])
