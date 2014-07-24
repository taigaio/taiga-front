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


#############################################################################
## Create Members Lightbox Directive
#############################################################################

CreateMembersDirective = ($repo, $rootScope, $q, $confirm) ->
    template = _.template("""
    <fieldset>
        <input type="email" placeholder="Type an Email" data-required="true" />
        <select data-required="true">
            <% _.each(roleList, function(role) { %>
            <option value="<%- role.id %>"><%- role.name %></option>
            <% }); %>
        </select>
        <a class="icon icon-plus" href=""></a>
    <fieldset>
    """) # i18n

    link = ($scope, $el, $attrs) ->
        createFieldSet = ->
            ctx = {roleList: $scope.roles}
            return template(ctx)

        $scope.$on "membersform:new",  ->
            title = $el.find("h2")
            fieldSet = createFieldSet()
            title.after(fieldSet)

            $el.removeClass("hidden")

        $scope.$on "$destroy", ->
            $el.off()

        # Dom Event Handlers
        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $el.addClass("hidden")

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            fieldSet = target.parent()

            fieldSet.remove()

        $el.on "click", ".icon-plus", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            fieldSet = target.parent()

            target.removeClass("icon-plus").addClass("icon-delete")
            newFieldSet = createFieldSet()
            fieldSet.after(newFieldSet)

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            onSuccess = (data) ->
                $el.addClass("hidden")
                $confirm.notify("success")
                $rootScope.$broadcast("membersform:new:success")

            onError = (data) ->
                $el.addClass("hidden")
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
                    role: fieldset.children("select").val()
                    project: $ctrl.scope.project.id
                }

            promises = _.map invitations, (inv) ->
                return $repo.create("memberships", inv)

            $q.all(promises).then(onSuccess, onError)

    return {link: link}

module.directive("tgLbCreateMembers", ["$tgRepo", "$rootScope", "$q", "$tgConfirm",
                                       CreateMembersDirective])
