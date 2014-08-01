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

AttachmentsDirective = ($repo, $rs) ->
    link = ($scope, $el, $attrs, $model) ->
        $ctrl = $el.controller()
        $scope.uploadingFiles = []

        ###########
        ## Drag & drop
        ###########
        tdom = $el.find("div.attachment-body.sortable")

        tdom.sortable({
            items: "div.single-attachment"
            handle: "a.settings.icon.icon-drag-v"
            dropOnEmpty: true
            revert: 400
            axis: "y"
            placeholder: "sortable-placeholder single-attachment"
        })

        tdom.on "sortstop", (event, ui) ->
            attachment = ui.item.scope().attach
            newIndex = ui.item.index()
            index = $scope.attachments.indexOf(attachment)

            return if index == newIndex

            # Move attachment to newIndex and recalculate order
            $scope.attachments.splice(index, 1)
            $scope.attachments.splice(newIndex, 0, attachment)
            _.forEach $scope.attachments, (attach, idx) ->
                attach.order = idx+1

            # Save or revert changes
            $repo.saveAll($scope.attachments).then null, ->
                _.forEach $scope.attachments, attach ->
                    attach.revert()
                _.sorBy($scope.attachments, 'order')

        ###########
        ## Total attachments counter
        ###########
        $scope.$watch "attachmentsCount", (count) ->
            $el.find("span.attachments-num").html(count)

        ###########
        ## Show/Hide deprecated attachments
        ###########
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
                                        .prop("title", "hide deprecated attachments") # TODO: i18n
                $el.find("div.single-attachment.deprecated").removeClass("hidden")
            else
                target.find("span.text").html("+ show deprecated attachments") # TODO: i18n
                                        .prop("title", "show deprecated attachments") # TODO: i18n
                $el.find("div.single-attachment.deprecated").addClass("hidden")

        ###########
        ## Add Attachments
        ###########
        $el.on "click", "a.add-attach", ->
            angular.element("input.add-attach").trigger("click")

        $el.on "change", "input.add-attach", ->
            files = _.map(event.target.files, (x) -> x)
            return if files.length < 1

            $scope.$apply =>
                if not $scope.uploadingFiles or $scope.uploadingFiles.length == 0
                    $scope.uploadingFiles = files
                else
                    $scope.uploadingFiles = scope.uploadingFiles.concat(files)

            urlName = $ctrl.attachmentsUrlName
            projectId = $scope.projectId
            objectId = $model.$modelValue.id

            _.forEach files, (file) ->
                promise = $rs.attachments.create(urlName, projectId, objectId, file)

                promise.then (data) ->
                    $scope.uploadingFiles = _.without($scope.uploadingFiles, file)
                    data.isCreatedRightNow = true
                    $scope.attachments[$scope.attachments.length] = data
                    $scope.attachmentsCount = $scope.attachments.length

                promise.then null, (data) ->
                    $scope.uploadingFiles = _.without($scope.uploadingFiles, file)
                    $confirm.notify("error", null, "We have not been able to upload '#{file.name}'.") #TODO: i18in

        ###########
        ## On destroy
        ###########
        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link,
        require: "ngModel"
    }

module.directive("tgAttachments", ["$tgRepo", "$tgResources", AttachmentsDirective])


#############################################################################
## Attachment Directive
#############################################################################

AttachmentDirective = ($log, $repo, $confirm) ->
    singleAttachment = _.template("""
    <div class="attachment-name">
        <a href="<%- url %>" title="<%- name %>" target="_blank">
            <span class="icon icon-documents"></span>
            <span><%- name %><span>
        </a>
    </div>
    <div class="attachment-size">
        <span><%- size %></span>
    </div>
    <div class="attachment-comments">
        <span class="deprecated-file hidden">(deprecated)</span>
        <span><%- description %></span>
    </div>
    <div class="attachment-settings">
        <a class="settings icon icon-edit" href="" title="Edit"></a>
        <a class="settings icon icon-delete" href="" title="Delete"></a>
        <a class="settings icon icon-drag-v" href="" title=""Drag"></a>
    </div>
    """) #TODO: i18n

    singleAttachmentEditable = _.template("""
    <div class="attachment-name">
        <span class="icon.icon-document"></span>
        <a href="<%- url %>" title="<%- name %>" target="_blank"><%- name %></a>
    </div>
    <div class="attachment-size">
        <span><%- size %></span>
    </div>
    <div class="editable editable-attachment-comment">
        <input type="text" name="description" maxlength="140"
               value="<%- description %>""
               placeholder="Type a short description" />
    </div>
    <div class="editable editable-attachment-deprecated">
        <input type="checkbox" name="is-deprecated" id="attach-<%- id %>-is-deprecated"
               <% if (isDeprecated){ %>checked<% } %> />
        <label for="attach-<%- id %>-is-deprecated">Deprecated?</label>
    </div>
    <div class="attachment-settings">
        <a class="editable-settings icon icon-floppy" href="" title="Save"></a>
        <a class="editable-settings icon icon-delete" href="" title="Cancel"></a>
    </div>
    """) # TODO: i18n

    link = ($scope, $el, $attrs) ->
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
                $el.find(".deprecated-file").removeClass('hidden')
                if $scope.showDeprecatedAttachments
                    $el.removeClass("hidden")
            else
                $el.removeClass("deprecated")
                $el.removeClass("hidden")

        ###########
        ## Initialize
        ###########
        if not $attrs.tgAttachment?
            return $log.error "AttachmentDirective the directive need an attachment"

        attachment = $scope.$eval($attrs.tgAttachment)
        render(attachment, attachment.isCreatedRightNow)
        delete attachment.isCreatedRightNow

        ###########
        ## Actions (on view mode)
        ###########
        $el.on "click", "a.settings.icon-edit", (event) ->
            event.preventDefault()
            render(attachment, true)

        $el.on "click", "a.settings.icon-delete", (event) ->
            event.preventDefault()

            title = "Delete attachment"  #TODO: i18in
            subtitle = "the attachment '#{attachment.name}'" #TODO: i18in

            onSuccess = ->
                $ctrl.loadAttachments(attachment.object_id)
                $confirm.notify("success", null, "We've deleted #{subtitle}.") #TODO: i18in

            onError = ->
                $confirm.notify("error", null, "We have not been able to delete #{subtitle}.") #TODO: i18in

            $confirm.ask(title, subtitle).then ->
                $repo.remove(attachment).then(onSuccess, onError)

        ###########
        ## Actions (on edit mode)
        ###########
        $el.on "click", "a.editable-settings.icon-delete", (event) ->
            event.preventDefault()
            render(attachment)

        $el.on "click", "a.editable-settings.icon-floppy", (event) ->
            newDescription = $el.find("input[name='description']").val()
            newIsDeprecated = $el.find("input[name='is-deprecated']").prop("checked")

            if newDescription != attachment.description
                attachment.description = newDescription
            if newIsDeprecated != attachment.is_deprecated
                attachment.is_deprecated = newIsDeprecated

            onSuccess = ->
                $ctrl.loadAttachments(attachment.object_id)
                $confirm.notify("success")

            onError = ->
                $confirm.notify("error")

            $repo.save(attachment).then(onSuccess, onError)

        ###########
        ## On destroy
        ###########
        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgAttachment", ["$log", "$tgRepo", "$tgConfirm",
                                  AttachmentDirective])
