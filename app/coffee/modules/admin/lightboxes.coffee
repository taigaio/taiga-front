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
# File: modules/admin/lightboxes.coffee
###

taiga = @.taiga

module = angular.module("taigaKanban")

MAX_MEMBERSHIP_FIELDSETS = 6

#############################################################################
## Create Members Lightbox Directive
#############################################################################

CreateMembersDirective = ($rs, $rootScope, $confirm, lightboxService) ->
    template = _.template("""
    <div class="add-member-wrapper">
        <fieldset>
            <input type="email" placeholder="Type an Email" data-required="true" />
        </fieldset>
        <fieldset>
            <select data-required="true">
                <% _.each(roleList, function(role) { %>
                <option value="<%- role.id %>"><%- role.name %></option>
                <% }); %>
            </select>
            <a class="icon icon-plus add-fieldset" href=""></a>
        </fieldset>
    </div>
    """) # i18n

    link = ($scope, $el, $attrs) ->
        createFieldSet = ->
            ctx = {roleList: $scope.roles}
            return template(ctx)

        resetForm = ->
            $el.find("form > fieldset").remove()

            title = $el.find("h2")
            fieldSet = createFieldSet()
            title.after(fieldSet)

        $scope.$on "membersform:new",  ->
            resetForm()
            lightboxService.open($el)

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".delete-fieldset", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            fieldSet = target.parent()

            fieldSet.remove()

            lastActionButton = $el.find("fieldset:last > a")
            if lastActionButton.hasClass("icon-delete delete-fieldset")
                lastActionButton.removeClass("icon-delete delete-fieldset")
                                .addClass("icon-plus add-fieldset")

        $el.on "click", ".add-fieldset", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            fieldSet = target.parent()

            target.removeClass("icon-plus add-fieldset")
                  .addClass("icon-delete delete-fieldset")

            newFieldSet = createFieldSet()
            fieldSet.after(newFieldSet)

            if $el.find("fieldset").length == MAX_MEMBERSHIP_FIELDSETS
                $el.find("fieldset:last > a").removeClass("icon-plus add-fieldset")
                                             .addClass("icon-delete delete-fieldset")

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            onSuccess = (data) ->
                lightboxService.close($el)
                $confirm.notify("success")
                $rootScope.$broadcast("membersform:new:success")

            onError = (data) ->
                lightboxService.close($el)
                $confirm.notify("error")
                $rootScope.$broadcast("membersform:new:error")

            form = $el.find("form").checksley()
            if not form.validate()
                return

            fieldSets = $el.find("form > fieldset")

            invitations = _.map fieldSets, (fs) ->
                fieldset = angular.element(fs)
                return {
                    email: fieldset.children("input").val()
                    role_id: fieldset.children("select").val()
                }

            $rs.memberships.bulkCreateMemberships($scope.project.id, invitations).then(onSuccess, onError)

    return {link: link}

module.directive("tgLbCreateMembers", ["$tgResources", "$rootScope", "$tgConfirm", "lightboxService",
                                       CreateMembersDirective])
