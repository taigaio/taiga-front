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
# File: modules/admin/lightboxes.coffee
###

taiga = @.taiga
debounce = @.taiga.debounce

module = angular.module("taigaKanban")

MAX_MEMBERSHIP_FIELDSETS = 4

#############################################################################
## Create Members Lightbox Directive
#############################################################################

CreateMembersDirective = ($rs, $rootScope, $confirm, $loading, lightboxService, $compile) ->
    extraTextTemplate = """
    <fieldset class="extra-text">
        <textarea ng-attr-placeholder="{{'LIGHTBOX.CREATE_MEMBER.PLACEHOLDER_INVITATION_TEXT' | translate}}"
                  maxlength="255"></textarea>
    </fieldset>
    """

    template = _.template("""
    <div class="add-member-wrapper">
        <fieldset>
            <input tg-capslock type="email" placeholder="{{'LIGHTBOX.CREATE_MEMBER.PLACEHOLDER_TYPE_EMAIL' | translate}}"
                   <% if(required) { %> data-required="true" <% } %> data-type="email" />
        </fieldset>
        <fieldset>
            <select <% if(required) { %> data-required="true" <% } %> data-required="true">
                <% _.each(roleList, function(role) { %>
                <option value="<%- role.id %>"><%- role.name %></option>
                <% }); %>
            </select>
            <a class="add-fieldset" href="">
                <svg class="icon icon-add">
                    <use xlink:href="#icon-add">
                </svg>
            </a>
        </fieldset>
    </div>
    """)

    link = ($scope, $el, $attrs) ->
        createButton = (type) ->
            html = "<svg class='icon " + type + "'><use xlink:href='#" + type + "'></svg>";
            console.log html
            return html

        createFieldSet = (required = true)->
            ctx = {roleList: $scope.project.roles, required: required}
            return $compile(template(ctx))($scope)

        resetForm = ->
            $el.find("form textarea").remove()
            $el.find("form .add-member-wrapper").remove()

            invitations = $el.find(".add-member-forms")
            invitations.html($compile(extraTextTemplate)($scope))

            fieldSet = createFieldSet()
            invitations.prepend(fieldSet)

        $scope.$on "membersform:new",  ->
            resetForm()
            lightboxService.open($el)

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".delete-fieldset", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            fieldSet = target.closest('.add-member-wrapper')

            fieldSet.remove()

            lastActionButton = $el.find(".add-member-wrapper fieldset:last > a")
            if lastActionButton.hasClass("delete-fieldset")
                lastActionButton.removeClass("delete-fieldset").addClass("add-fieldset")
                svg = createButton('icon-add')
                lastActionButton.html(svg)

        $el.on "click", ".add-fieldset", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            fieldSet = target.closest('.add-member-wrapper')

            target.removeClass("add-fieldset").addClass("delete-fieldset")
            svg = createButton('icon-trash')
            target.html(svg)

            newFieldSet = createFieldSet(false)
            fieldSet.after(newFieldSet)

            $scope.$digest() # To compile newFieldSet and translate text

            if $el.find(".add-member-wrapper").length == MAX_MEMBERSHIP_FIELDSETS
                $el.find(".add-member-wrapper fieldset:last > a")
                    .removeClass("add-fieldset").addClass("delete-fieldset")
                svg = createButton('icon-trash')
                $el.find(".add-member-wrapper fieldset:last > a").html(svg)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            currentLoading = $loading()
                .target(submitButton)
                .start()

            onSuccess = (data) ->
                currentLoading.finish()
                lightboxService.close($el)
                $confirm.notify("success")
                $rootScope.$broadcast("membersform:new:success")

            onError = (data) ->
                currentLoading.finish()
                lightboxService.close($el)
                $confirm.notify("error")
                $rootScope.$broadcast("membersform:new:error")

            form = $el.find("form").checksley()

            #checksley find new fields
            form.destroy()
            form.initialize()
            if not form.validate()
                return

            memberWrappers = $el.find("form .add-member-wrapper")
            memberWrappers = _.filter memberWrappers, (mw) ->
                angular.element(mw).find("input").hasClass('checksley-ok')

            invitations = _.map memberWrappers, (mw) ->
                memberWrapper = angular.element(mw)
                email =  memberWrapper.find("input")
                role = memberWrapper.find("select")

                return {
                    email: email.val()
                    role_id: role.val()
                }

            if invitations.length
                invitation_extra_text = $el.find("form textarea").val()

                promise = $rs.memberships.bulkCreateMemberships($scope.project.id,
                                                      invitations, invitation_extra_text)
                promise.then(onSuccess, onError)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

    return {link: link}

module.directive("tgLbCreateMembers", ["$tgResources", "$rootScope", "$tgConfirm", "$tgLoading",
                                       "lightboxService", "$compile", CreateMembersDirective])
