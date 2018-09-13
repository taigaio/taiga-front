###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/attachments-full/attachments-full.directive.coffee
###

bindOnce = @.taiga.bindOnce

AttachmentsFullDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        bindOnce scope, 'vm.objId', (value) ->
            ctrl.loadAttachments()

    return {
        scope: {},
        bindToController: {
            type: "@",
            objId: "=",
            projectId: "=",
            editPermission: "@"
        },
        controller: "AttachmentsFull",
        controllerAs: "vm",
        templateUrl: "components/attachments-full/attachments-full.html",
        link: link
    }

AttachmentsFullDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentsFull", AttachmentsFullDirective)
