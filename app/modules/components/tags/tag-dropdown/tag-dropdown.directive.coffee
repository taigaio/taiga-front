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
# File: tag-line.directive.coffee
###

module = angular.module('taigaCommon')

TagOptionDirective = () ->
    select = (selected) ->
        selected.addClass('selected')

        selectedPosition = selected.position().top + selected.outerHeight()
        containerHeight = selected.parent().outerHeight()

        if selectedPosition > containerHeight
            diff = selectedPosition - containerHeight
            selected.parent().scrollTop(selected.parent().scrollTop() + diff)
        else if selected.position().top < 0
            selected.parent().scrollTop(selected.parent().scrollTop() + selected.position().top)

    dispatch = (el, code, scope) ->
        activeElement = el.find(".selected")

        # Key: down
        if code == 40
            if not activeElement.length
                select(el.find('li:first'))
            else
                next = activeElement.next('li')
                if next.length
                    activeElement.removeClass('selected')
                    select(next)
        # Key: up
        else if code == 38
            if not activeElement.length
                select(el.find('li:last'))
            else
                prev = activeElement.prev('li')

                if prev.length
                    activeElement.removeClass('selected')
                    select(prev)

    stop = ->
        $(document).off(".tags-keyboard-navigation")

    link = (scope, el) ->
        stop()

        $(el).parent().on "keydown.tags-keyboard-navigation", (event) =>
            code = if event.keyCode then event.keyCode else event.which

            if code == 40 || code == 38
                event.preventDefault()

                dispatch(el, code, scope)

        scope.$on("$destroy", stop)

    return {
        link: link,
        templateUrl:"components/tags/tag-dropdown/tag-dropdown.html",
        scope: {
            onSelectTag: "&",
            colorArray: "=",
            tag: "="
        }
    }

module.directive("tgTagsDropdown", TagOptionDirective)
