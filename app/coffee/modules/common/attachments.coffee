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
# File: modules/common/attachments.coffee
###

taiga = @.taiga
sizeFormat = @.taiga.sizeFormat

module = angular.module("taigaCommon")


#############################################################################
## Attachments Directive
#############################################################################

AttachmentsDirective = ->
    link = ($scope, $el, $attrs, $model) ->
        #$ctrl = $el.controller()
        ## Total attachments counter
        $scope.$watch "attachmentsCount", (attachmentsCount) ->
            $el.find("span.attachments-num").html(attachmentsCount)

        ## See deprecated attachments
        $scope.showDeprecatedAttachments = false

        $scope.$watch "deprecatedAttachmentsCount", (deprecatedAttachmentsCount) ->
            $el.find("span.more-attachments-num").html("(#{deprecatedAttachmentsCount} deprecated)") # TODO: i18n

            if deprecatedAttachmentsCount
                $el.find("a.more-attachments").removeClass("hidden")
            else
                $el.find("a.more-attachments").addClass("hidden")

        $el.on "click", "a.more-attachments", ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            $scope.showDeprecatedAttachments = not $scope.showDeprecatedAttachments

            if $scope.showDeprecatedAttachments
                target.find("span.text").html("- hide deprecated attachments") # TODO: i18n
                $el.find("div.single-attachment.deprecated").removeClass("hidden")
            else
                target.find("span.text").html("+ show deprecated attachments") # TODO: i18n
                $el.find("div.single-attachment.deprecated").addClass("hidden")

        ## On destroy
        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link,
        require: "ngModel"
    }

module.directive("tgAttachments", [AttachmentsDirective])


#############################################################################
## Attachment Directive
#############################################################################

AttachmentDirective = ($log, $repo, $rs, $confirm) ->
    singleAttachment = _.template("""
    <div class="attachment-name">
        <span class="icon.icon-document"></span>
        <a href="<%- url %>" title="<%- name %>" target="_blank"><%- name %></a>
    </div>
    <div class="attachment-comment">
        <span class="attachment-size">(<%- size %>)</span>
        <span><%- description %></span>
    </div>
    <a class="settings icon icon-edit" href="" title="Edit"></a>
    <a class="settings icon icon-delete" href="" title="Delete"></a>
    <a class="settings icon icon-drag-v" href="" title=""Drag"></a>
    """) #TODO: i18n

    singleAttachmentEditable = _.template("""
    <div class="attachment-name">
        <span class="icon.icon-document"></span>
        <a href="<%- url %>" title="<%- name %>" target="_blank"><%- name %></a>
    </div>
    <div class="editable editable-attachment-comment">
        <span class="attachment-size">(<%- size %>)</span>
        <input type="text" name="description"
               value="<%- description %>""
               placeholder="Type a short description" />
    </div>
    <div class="editable editable-attachment-deprecated">
        <input type="checkbox" name="is-deprecated" id="attach-<%- id %>-is-deprecated"
               <% if (isDeprecated){ %>checked<% } %> />
        <label for="attach-<%- id %>-is-deprecated">Deprecated?</label>
    </div>
    <a class="editable icon icon-floppy" href="" title="Save"></a>
    <a class="editable icon icon-delete" href="" title="Cancel"></a>
    """) # TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        $ctrl = $el.controller()

        render = (attachment, isEditable=false) ->
            ctx = {
                id: attachment.id
                name: attachment.name
                url: attachment.url
                size: sizeFormat(attachment.size)
                description: attachment.description
                isDeprecated: attachment.is_deprecated
            }

            if isEditable
                html = singleAttachmentEditable(ctx)
            else
                html = singleAttachment(ctx)

            $el.html(html)

            if attachment.is_deprecated
                $el.addClass("deprecated")
                if $scope.showDeprecatedAttachments
                    $el.removeClass("hidden")
            else
                $el.removeClass("deprecated")
                $el.removeClass("hidden")

        ## Initialize
        if not $attrs.tgAttachment?
            return $log.error "AttachmentDirective the directive need an attachment"

        attachment = $scope.$eval($attrs.tgAttachment)
        render(attachment)

        ## Actions (on view mode)
        $el.on "click", "a.settings.icon-edit", (event) ->
            event.preventDefault()
            render(attachment, true)

        $el.on "click", "a.settings.icon-delete", (event) ->
            event.preventDefault()

            title = "Delete attachment" # i18n
            subtitle = "the attachment '#{attachment.name}'"

            onSuccess = ->
                $ctrl.loadAttachments(attachment.object_id)
                $confirm.notify("success", null, "We've deleted #{subtitle}.") #TODO: i18in

            onError = ->
                $confirm.notify("error", null, "We have not been able to delete #{subtitle}.") #TODO: i18in

            $confirm.ask(title, subtitle).then ->
                $repo.remove(attachment).then(onSuccess, onError)

        ## Actions (on edit mode)
        $el.on "click", "a.editable.icon-delete", (event) ->
            event.preventDefault()
            render(attachment)

        $el.on "click", "a.editable.icon-floppy", (event) ->
            newDescription = $el.find("input[name='description']").val()
            newIsDeprecated = $el.find("input[name='is-deprecated']").prop("checked")

            if newDescription != attachment.description
                attachment.setAttr("description", newDescription)
            if newIsDeprecated != attachment.is_deprecated
                attachment.setAttr("is_deprecated", newIsDeprecated)

            onSuccess = ->
                $ctrl.loadAttachments(attachment.object_id)
                $confirm.notify("success")

            onError = ->
                $confirm.notify("error")

            if attachment.isModified()
                $repo.save(attachment).then(onSuccess, onError)

        ## On destroy
        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link,
        require: "ngModel"
    }

module.directive("tgAttachment", ["$log", "$tgRepo", "$tgResources", "$tgConfirm",
                                  AttachmentDirective])
