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
# File: modules/common/lightboxes.coffee
###

module = angular.module("taigaCommon")

bindOnce = @.taiga.bindOnce
timeout = @.taiga.timeout
debounce = @.taiga.debounce

#############################################################################
## Common Lightbox Services
#############################################################################

# the lightboxContent hide/show doesn't have sense because is an IE hack
class LightboxService extends taiga.Service
    constructor: (@animationFrame, @q) ->

    open: ($el) ->
        defered = @q.defer()

        lightboxContent = $el.children().not(".close")
        lightboxContent.hide()

        $el.css('display', 'flex')

        $el.find('input,textarea').first().focus()

        @animationFrame.add =>
            $el.addClass("open")
            lightboxContent.show()
            defered.resolve()

        docEl = angular.element(document)
        docEl.on "keydown.lightbox", (e) =>
            code = if e.keyCode then e.keyCode else e.which
            @.close($el) if code == 27

        return defered.promise

    close: ($el) ->
        docEl = angular.element(document)
        docEl.off(".lightbox")
        docEl.off(".keyboard-navigation") # Hack: to fix problems in the WYSIWYG textareas when press ENTER
        $el.one "transitionend", =>
            $el.removeAttr('style')
            $el.removeClass("open").removeClass('close')

        $el.addClass('close')

    closeAll: ->
        docEl = angular.element(document)
        for lightboxEl in docEl.find(".lightbox.open")
            @.close($(lightboxEl))


module.service("lightboxService", ["animationFrame", "$q", LightboxService])


class LightboxKeyboardNavigationService extends taiga.Service
    stop: ->
        docEl = angular.element(document)
        docEl.off(".keyboard-navigation")

    dispatch: ($el, code) ->
        activeElement = $el.find(".active")

        # Key: enter
        if code == 13
            activeElement.trigger("click")

        # Key: down
        else if code == 40
            if not activeElement.length
                $el.find('.watcher-single:first').addClass('active')
            else
                next = activeElement.next('.watcher-single')
                if next.length
                    activeElement.removeClass('active')
                    next.addClass('active')
        # Key: up
        else if code == 38
            if not activeElement.length
                $el.find('.watcher-single:last').addClass('active')
            else
                prev = activeElement.prev('.watcher-single')

                if prev.length
                    activeElement.removeClass('active')
                    prev.addClass('active')

    init: ($el) ->
        @stop()
        docEl = angular.element(document)
        docEl.on "keydown.keyboard-navigation", (event) =>
            code = if event.keyCode then event.keyCode else event.which
            if code == 40 || code == 38 || code == 13
                event.preventDefault()
                @.dispatch($el, code)

module.service("lightboxKeyboardNavigationService", LightboxKeyboardNavigationService)


#############################################################################
## Generic Lighthbox Directive
#############################################################################

# This adds generic behavior to all blocks with lightbox class like
# close button event handlers.

LightboxDirective = (lightboxService) ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", ".close", (event) ->
            event.preventDefault()
            lightboxService.close($el)

    return {restrict: "C", link: link}

module.directive("lightbox", ["lightboxService", LightboxDirective])

#############################################################################
## Block Lightbox Directive
#############################################################################

# Issue/Userstory blocking message lightbox directive.

BlockLightboxDirective = ($rootscope, $tgrepo, $confirm, lightboxService, $loading, $qqueue) ->
    link = ($scope, $el, $attrs, $model) ->
        $el.find("h2.title").text($attrs.title)

        unblock = $qqueue.bindAdd (item, finishCallback) =>
            promise = $tgrepo.save(item)
            promise.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("history:reload")
                $model.$setViewValue(item)
                finishCallback()

            promise.then null, ->
                $confirm.notify("error")
                item.revert()
                $model.$setViewValue(item)

            promise.finally ->
                finishCallback()

            return promise

        block = $qqueue.bindAdd (item) =>
            $model.$setViewValue(item)

            $loading.start($el.find(".button-green"))

            promise = $tgrepo.save($model.$modelValue)
            promise.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("history:reload")

            promise.then null, ->
                $confirm.notify("error")
                item.revert()
                $model.$setViewValue(item)

            promise.finally ->
                $loading.finish($el.find(".button-green"))
                lightboxService.close($el)

        $scope.$on "block", ->
            $el.find(".reason").val($model.$modelValue.blocked_note)
            lightboxService.open($el)

        $scope.$on "unblock", (event, model, finishCallback) =>
            item = $model.$modelValue.clone()
            item.is_blocked = false
            item.blocked_note = ""

            unblock(item, finishCallback)

        $scope.$on "$destroy", ->
            $el.off()

        $el.on "click", ".button-green", (event) ->
            event.preventDefault()

            item = $model.$modelValue.clone()
            item.is_blocked = true
            item.blocked_note = $el.find(".reason").val()

            block(item)

    return {
        templateUrl: "common/lightbox/lightbox-block.html"
        link: link
        require: "ngModel"
    }

module.directive("tgLbBlock", ["$rootScope", "$tgRepo", "$tgConfirm", "lightboxService", "$tgLoading", "$tgQqueue", BlockLightboxDirective])


#############################################################################
## Generic Lightbox Blocking-Message Input Directive
#############################################################################

BlockingMessageInputDirective = ($log, $template) ->
    template = $template.get("common/lightbox/lightbox-blocking-message-input.html", true)

    link = ($scope, $el, $attrs, $model) ->
        if not $attrs.watch
            return $log.error "No watch attribute on tg-blocking-message-input directive"

        $scope.$watch $attrs.watch, (value) ->
            if value is not undefined and value == true
                $el.find(".blocked-note").removeClass("hidden")
            else
                $el.find(".blocked-note").addClass("hidden")

    templateFn = ($el, $attrs) ->
        return template({ngmodel: $attrs.ngModel})

    return {
        template: templateFn
        link: link
        require: "ngModel"
        restrict: "EA"
    }

module.directive("tgBlockingMessageInput", ["$log", "$tgTemplate", BlockingMessageInputDirective])


#############################################################################
## Create/Edit Userstory Lightbox Directive
#############################################################################

CreateEditUserstoryDirective = ($repo, $model, $rs, $rootScope, lightboxService, $loading) ->
    link = ($scope, $el, attrs) ->
        $scope.isNew = true

        $scope.$on "usform:new", (ctx, projectId, status, statusList) ->
            $scope.isNew = true
            $scope.usStatusList = statusList

            $scope.us = $model.make_model("userstories", {
                project: projectId
                points : {}
                status: status
                is_archived: false
                tags: []
            })

            # Update texts for creation
            $el.find(".button-green").html("Create") #TODO: i18n
            $el.find(".title").html("New user story  ") #TODO: i18n
            $el.find(".tag-input").val("")

            $el.find(".blocked-note").addClass("hidden")
            $el.find("label.blocked").removeClass("selected")
            $el.find("label.team-requirement").removeClass("selected")
            $el.find("label.client-requirement").removeClass("selected")

            lightboxService.open($el)

        $scope.$on "usform:edit", (ctx, us) ->
            $scope.us = us
            $scope.isNew = false

            # Update texts for edition
            $el.find(".button-green").html("Save") #TODO: i18n
            $el.find(".title").html("Edit user story  ") #TODO: i18n
            $el.find(".tag-input").val("")

            # Update requirement info (team, client or blocked)
            if us.is_blocked
                $el.find(".blocked-note").removeClass("hidden")
                $el.find("label.blocked").addClass("selected")
            else
                $el.find(".blocked-note").addClass("hidden")
                $el.find("label.blocked").removeClass("selected")

            if us.team_requirement
                $el.find("label.team-requirement").addClass("selected")
            else
                $el.find("label.team-requirement").removeClass("selected")
            if us.client_requirement
                $el.find("label.client-requirement").addClass("selected")
            else
                $el.find("label.client-requirement").removeClass("selected")

            lightboxService.open($el)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            $loading.start(submitButton)

            if $scope.isNew
                promise = $repo.create("userstories", $scope.us)
                broadcastEvent = "usform:new:success"
            else
                promise = $repo.save($scope.us)
                broadcastEvent = "usform:edit:success"

            promise.then (data) ->
                $loading.finish(submitButton)
                lightboxService.close($el)
                $rootScope.$broadcast(broadcastEvent, data)

            promise.then null, (data) ->
                $loading.finish(submitButton)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

        $el.on "click", ".close", (event) ->
            event.preventDefault()
            $scope.$apply ->
                $scope.us.revert()
            lightboxService.close($el)

        $el.keydown (event) ->
            code = if event.keyCode then event.keyCode else event.which
            if code == 27
                lightboxService.close($el)
                $scope.$apply ->
                    $scope.us.revert()

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateEditUserstory", [
    "$tgRepo",
    "$tgModel",
    "$tgResources",
    "$rootScope",
    "lightboxService",
    "$tgLoading",
    CreateEditUserstoryDirective
])


#############################################################################
## Creare Bulk Userstories Lightbox Directive
#############################################################################

CreateBulkUserstoriesDirective = ($repo, $rs, $rootscope, lightboxService, $loading) ->
    link = ($scope, $el, attrs) ->
        $scope.$on "usform:bulk", (ctx, projectId, status) ->
            $scope.new = {
                projectId: projectId
                statusId: status
                bulk: ""
            }
            lightboxService.open($el)

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley({onlyOneErrorElement: true})
            if not form.validate()
                return

            $loading.start(submitButton)

            promise = $rs.userstories.bulkCreate($scope.new.projectId, $scope.new.statusId, $scope.new.bulk)
            promise.then (result) ->
                $loading.finish(submitButton)
                $rootscope.$broadcast("usform:bulk:success", result)
                lightboxService.close($el)

            promise.then null, (data) ->
                $loading.finish(submitButton)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit
        $el.on "click", ".submit-button", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateBulkUserstories", [
    "$tgRepo",
    "$tgResources",
    "$rootScope",
    "lightboxService",
    "$tgLoading",
    CreateBulkUserstoriesDirective
])


#############################################################################
## AssignedTo Lightbox Directive
#############################################################################

AssignedToLightboxDirective = (lightboxService, lightboxKeyboardNavigationService, $template) ->
    link = ($scope, $el, $attrs) ->
        selectedUser = null
        selectedItem = null
        usersTemplate = $template.get("common/lightbox/lightbox-assigned-to-users.html", true)

        normalizeString = (string) ->
            normalizedString = string
            normalizedString = normalizedString.replace("Á", "A").replace("Ä", "A").replace("À", "A")
            normalizedString = normalizedString.replace("É", "E").replace("Ë", "E").replace("È", "E")
            normalizedString = normalizedString.replace("Í", "I").replace("Ï", "I").replace("Ì", "I")
            normalizedString = normalizedString.replace("Ó", "O").replace("Ö", "O").replace("Ò", "O")
            normalizedString = normalizedString.replace("Ú", "U").replace("Ü", "U").replace("Ù", "U")
            return normalizedString

        filterUsers = (text, user) ->
            username = user.full_name_display.toUpperCase()
            username = normalizeString(username)
            text = text.toUpperCase()
            text = normalizeString(text)
            return _.contains(username, text)

        render = (selected, text) ->
            users = _.clone($scope.activeUsers, true)
            users = _.reject(users, {"id": selected.id}) if selected?
            users = _.filter(users, _.partial(filterUsers, text)) if text?

            ctx = {
                selected: selected
                users: _.first(users, 5)
                showMore: users.length > 5
            }

            html = usersTemplate(ctx)
            $el.find("div.watchers").html(html)
            lightboxKeyboardNavigationService.init($el)

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "assigned-to:add", (ctx, item) ->
            selectedItem = item
            assignedToId = item.assigned_to
            selectedUser = $scope.usersById[assignedToId]

            render(selectedUser)
            lightboxService.open($el).then ->
                $el.find('input').focus()


        $scope.$watch "usersSearch", (searchingText) ->
            if searchingText?
                render(selectedUser, searchingText)
                $el.find('input').focus()

        $el.on "click", ".watcher-single", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            closeLightbox()

            $scope.$apply ->
                $scope.$broadcast("assigned-to:added", target.data("user-id"), selectedItem)
                $scope.usersSearch = null

        $el.on "click", ".remove-assigned-to", (event) ->
            event.preventDefault()
            event.stopPropagation()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("assigned-to:added", null, selectedItem)

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "common/lightbox/lightbox-assigned-to.html"
        link:link
    }


module.directive("tgLbAssignedto", ["lightboxService", "lightboxKeyboardNavigationService", "$tgTemplate", AssignedToLightboxDirective])


#############################################################################
## Watchers Lightbox directive
#############################################################################

WatchersLightboxDirective = ($repo, lightboxService, lightboxKeyboardNavigationService, $template) ->
    link = ($scope, $el, $attrs) ->
        selectedItem = null
        usersTemplate = $template.get("common/lightbox/lightbox-assigned-to-users.html", true)

        # Get prefiltered users by text
        # and without now watched users.
        getFilteredUsers = (text="") ->
            _filterUsers = (text, user) ->
                if selectedItem && _.find(selectedItem.watchers, (x) -> x == user.id)
                    return false

                username = user.full_name_display.toUpperCase()
                text = text.toUpperCase()
                return _.contains(username, text)

            users = _.clone($scope.activeUsers, true)
            users = _.filter(users, _.partial(_filterUsers, text))
            return users

        # Render the specific list of users.
        render = (users) ->
            ctx = {
                selected: false
                users: _.first(users, 5)
                showMore: users.length > 5
            }

            html = usersTemplate(ctx)
            $el.find("div.watchers").html(html)

        closeLightbox = () ->
            lightboxKeyboardNavigationService.stop()
            lightboxService.close($el)

        $scope.$on "watcher:add", (ctx, item) ->
            selectedItem = item

            users = getFilteredUsers()
            render(users)

            lightboxService.open($el).then ->
                $el.find("input").focus()
            lightboxKeyboardNavigationService.init($el)

        $scope.$watch "usersSearch", (searchingText) ->
            if not searchingText?
                return

            users = getFilteredUsers(searchingText)
            render(users)
            $el.find("input").focus()

        $el.on "click", ".watcher-single", debounce 2000, (event) ->
            closeLightbox()

            event.preventDefault()
            target = angular.element(event.currentTarget)

            $scope.$apply ->
                $scope.usersSearch = null
                $scope.$broadcast("watcher:added", target.data("user-id"))

        $el.on "click", ".close", (event) ->
            event.preventDefault()

            closeLightbox()

            $scope.$apply ->
                $scope.usersSearch = null

        $scope.$on "$destroy", ->
            $el.off()

    return {
        templateUrl: "common/lightbox/lightbox-users.html"
        link:link
    }

module.directive("tgLbWatchers", ["$tgRepo", "lightboxService", "lightboxKeyboardNavigationService", "$tgTemplate", WatchersLightboxDirective])

#############################################################################
## Notion Lightbox Directive
#############################################################################

# Lightbox
NotionLightboxDirective = (lightboxService) ->
    link = ($scope, $el, $attrs, $model) ->
        $scope.$on "notion:open", (event, lightboxId) ->
            if $el.attr("id") == lightboxId
                lightboxService.open($el)

        $el.on "click", ".button-green", (event) ->
            lightboxService.close($el)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgLbNotion", ["lightboxService", NotionLightboxDirective])


# Button
NotionButtonDirective = ($log, $rootScope) ->
    link = ($scope, $el, $attrs, $model) ->
        if not $attrs.tgLbNotionButton?
            return $log.error "NotionButtonDirective: the directive need the id of the notion lightbox"

        $el.on "click", ->
            $rootScope.$broadcast("notion:open", $attrs.tgLbNotionButton)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgLbNotionButton", ["$log", "$rootScope", NotionButtonDirective])
