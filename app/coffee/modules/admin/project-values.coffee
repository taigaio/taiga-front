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
## Project values status Controller
#############################################################################

class ProjectValuesStatusController extends mixOf(taiga.Controller, taiga.PageMixin)
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
        @scope.sectionName = "Project Values" #i18n
        @scope.project = {}

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

        @scope.$on("admin:project-values:status:move", @.moveStatus)

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            return project

    loadStatus: =>
        #TODO:
        return @rs[@scope.resource].listStatuses(@scope.projectId).then (statuses) =>
            @scope.statuses = statuses
            @scope.maxStatusOrder = _.max(statuses, "order").order

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then( => @q.all([
            @.loadProject(),
            @.loadStatus(),
        ]))

    moveStatus: (ctx, itemStatus, itemIndex) =>
        statuses = @scope.statuses
        r = statuses.indexOf(itemStatus)
        statuses.splice(r, 1)
        statuses.splice(itemIndex, 0, itemStatus)
        _.each statuses, (usStatus, index) ->
            usStatus.order = index

        @repo.saveAll(statuses)

module.controller("ProjectValuesStatusController", ProjectValuesStatusController)

#############################################################################
## Project values status directive
#############################################################################

ProjectStatusDirective = ($log, $repo, $confirm, $location) ->

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
            handle: ".row.table-main.visualization",
            dropOnEmpty: true
            connectWith: ".project-values-body"
            revert: 400
            axis: "y"
        })

        tdom.on "sortstop", (event, ui) ->
            parentEl = ui.item.parent()
            itemEl = ui.item
            itemStatus = itemEl.scope().status
            itemIndex = itemEl.index()
            $scope.$broadcast("admin:project-values:status:move", itemStatus, itemIndex)

        $scope.$on "$destroy", ->
            $el.off()

    #########################
    ## Status Link
    #########################

    linkStatus = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        statusType = $attrs.type

        initializeNewStatus = ->
            $scope.newStatus = {
                "name": ""
                "is_closed": false
            }

        initializeNewStatus()
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
            $el.find(".new-status").css('display': 'flex')

        $el.on "click", ".add-new", (event) ->
            event.preventDefault()
            form = $el.find(".new-status").parents("form").checksley()
            return if not form.validate()

            $scope.newStatus.project = $scope.project.id
            $scope.newStatus.order = $scope.maxStatusOrder + 1
            promise = $repo.create(statusType, $scope.newStatus)
            promise.then =>
                $ctrl.loadStatus()
                $el.find(".new-status").hide()
                initializeNewStatus()

            promise.then null, (data) ->
                form.setErrors(data)

        $el.on "click", ".delete-new", (event) ->
            event.preventDefault()
            $el.find(".new-status").hide()
            initializeNewStatus()

        $el.on "click", ".edit-status", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            row = target.parents(".row.table-main")
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
                row = target.parents(".row.table-main")
                row.hide()
                row.siblings(".visualization").css("display": "flex")

            promise.then null, (data) ->
                form.setErrors(data)

        $el.on "click", ".cancel", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            row = target.parents(".row.table-main")
            row.hide()
            row.siblings(".visualization").css("display": "flex")

        $el.on "click", ".delete-status", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            status = target.scope().status

            #TODO: i18n
            title = "Delete status"
            subtitle = status.name
            $confirm.ask(title, subtitle).then =>
                $repo.remove(status).then =>
                    $ctrl.loadStatus()

    link = ($scope, $el, $attrs) ->
        linkDragAndDrop($scope, $el, $attrs)
        linkStatus($scope, $el, $attrs)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgProjectStatus", ["$log", "$tgRepo", "$tgConfirm", "$tgLocation", ProjectStatusDirective])


#############################################################################
## Color selection directive
#############################################################################

ColorSelectionDirective = () ->

    #########################
    ## Color selection Link
    #########################

    link = ($scope, $el, $attrs, $model) ->
        $ctrl = $el.controller()

        $el.on "click", ".current-color", (event) ->
            # Showing the color selector
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            $el.find(".select-color").hide()
            target.siblings(".select-color").show()
            # Hide when click outside
            body = angular.element("body")
            body.on "click", (event) =>
                if angular.element(event.target).parent(".select-color").length == 0
                    $el.find(".select-color").hide()
                    body.unbind("click")

        $el.on "click", ".select-color .color", (event) ->
            # Selecting one color on color selector
            event.preventDefault()
            target = angular.element(event.currentTarget)
            $scope.$apply ->
                $model.$modelValue.color = target.data("color")
            $el.find(".select-color").hide()

        $scope.$on "$destroy", ->
            $el.off()

      return {
          link: link
          require:"ngModel"
      }

module.directive("tgColorSelection", ColorSelectionDirective)
