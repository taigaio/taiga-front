###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/backlog/sortable.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy

module = angular.module("taigaBacklog")


#############################################################################
## Sortable Directive
#############################################################################

deleteElement = (el) ->
    el.scope().$destroy()
    el.off()
    el.remove()

BacklogSortableDirective = ($repo, $rs, $rootscope, $tgConfirm, $translate) ->
    # Notes about jquery bug:
    # http://stackoverflow.com/questions/5791886/jquery-draggable-shows-
    # helper-in-wrong-place-when-scrolled-down-page

    link = ($scope, $el, $attrs) ->
        getUsIndex = (us) =>
            return $(us).index(".backlog-table-body .row")

        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if not (project.my_permissions.indexOf("modify_us") > -1)
                return

            filterError = ->
                text = $translate.instant("BACKLOG.SORTABLE_FILTER_ERROR")
                $tgConfirm.notify("error", text)

            $el.sortable({
                items: ".us-item-row",
                cancel: ".popover"
                connectWith: ".sprint"
                dropOnEmpty: true
                placeholder: "row us-item-row us-item-drag sortable-placeholder"
                scroll: true
                disableHorizontalScroll: true
                # A consequence of length of backlog user story item
                # the default tolerance ("intersection") not works properly.
                tolerance: "pointer"
                # Revert on backlog is disabled bacause it works bad. Something
                # on the current taiga backlog structure or style makes jquery ui
                # works unexpectly (in some circumstances calculates wrong
                # position for revert).
                revert: false
                start: () ->
                    $(document.body).addClass("drag-active")
                stop: () ->
                    $(document.body).removeClass("drag-active")

                    if $el.hasClass("active-filters")
                        $el.sortable("cancel")
                        filterError()
            })

            $el.on "multiplesortreceive", (event, ui) ->
                if $el.hasClass("active-filters")
                    ui.source.sortable("cancel")
                    filterError()

                    return

                itemUs = ui.item.scope().us
                itemIndex = getUsIndex(ui.item)

                deleteElement(ui.item)

                $scope.$emit("sprint:us:move", [itemUs], itemIndex, null)
                ui.item.find('a').removeClass('noclick')

            $el.on "multiplesortstop", (event, ui) ->
                # When parent not exists, do nothing
                if $(ui.items[0]).parent().length == 0
                    return

                if $el.hasClass("active-filters")
                    return

                items = _.sortBy ui.items, (item) ->
                    return $(item).index()

                index = _.min _.map items, (item) ->
                    return getUsIndex(item)

                us = _.map items, (item) ->
                    item = $(item)
                    itemUs = item.scope().us

                    # HACK: setTimeout prevents that firefox click
                    # event fires just after drag ends
                    setTimeout ( =>
                        item.find('a').removeClass('noclick')
                    ), 300

                    return itemUs

                $scope.$emit("sprint:us:move", us, index, null)

            $el.on "sortstart", (event, ui) ->
                ui.item.find('a').addClass('noclick')

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

BacklogEmptySortableDirective = ($repo, $rs, $rootscope) ->
    # Notes about jquery bug:
    # http://stackoverflow.com/questions/5791886/jquery-draggable-shows-
    # helper-in-wrong-place-when-scrolled-down-page

    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if project.my_permissions.indexOf("modify_us") > -1
                $el.sortable({
                    items: ".us-item-row",
                    dropOnEmpty: true
                })

                $el.on "sortreceive", (event, ui) ->
                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()

                    deleteElement(ui.item)
                    $scope.$emit("sprint:us:move", [itemUs], itemIndex, null)

                    ui.item.find('a').removeClass('noclick')

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


SprintSortableDirective = ($repo, $rs, $rootscope) ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, "project", (project) ->
            # If the user has not enough permissions we don't enable the sortable
            if project.my_permissions.indexOf("modify_us") > -1
                $el.sortable({
                    scroll: true
                    dropOnEmpty: true
                    items: ".sprint-table .milestone-us-item-row"
                    disableHorizontalScroll: true
                    connectWith: ".sprint,.backlog-table-body,.empty-backlog"
                    placeholder: "row us-item-row sortable-placeholder"
                    forcePlaceholderSize:true
                })

                $el.on "multiplesortreceive", (event, ui) ->
                    items = _.sortBy ui.items, (item) ->
                        return $(item).index()

                    index = _.min _.map items, (item) ->
                        return $(item).index()

                    us = _.map items, (item) ->
                        item = $(item)
                        itemUs = item.scope().us

                        deleteElement(item)

                        return itemUs

                    $scope.$emit("sprint:us:move", us, index, $scope.sprint.id)

                $el.on "multiplesortstop", (event, ui) ->
                    # When parent not exists, do nothing
                    if ui.item.parent().length == 0
                        return

                    itemUs = ui.item.scope().us
                    itemIndex = ui.item.index()

                    # HACK: setTimeout prevents that firefox click
                    # event fires just after drag ends
                    setTimeout ( =>
                        ui.item.find('a').removeClass('noclick')
                    ), 300

                    $scope.$emit("sprint:us:move", [itemUs], itemIndex, $scope.sprint.id)

                $el.on "sortstart", (event, ui) ->
                    ui.item.find('a').addClass('noclick')

    return {link:link}


module.directive("tgBacklogSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "$tgConfirm",
    "$translate",
    BacklogSortableDirective
])

module.directive("tgBacklogEmptySortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    BacklogEmptySortableDirective
])

module.directive("tgSprintSortable", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    SprintSortableDirective
])
