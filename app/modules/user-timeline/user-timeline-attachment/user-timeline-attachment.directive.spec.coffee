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
# File: user-timeline/user-timeline-attachment/user-timeline-attachment.directive.spec.coffee
###

describe "userTimelineAttachmentDirective", () ->
    element = scope = compile = provide = null
    mockTgTemplate = null
    template = "<div tg-user-timeline-attachment='attachment'></div>"

    _mockTgTemplate= () ->
        mockTgTemplate = {
            get: sinon.stub()
        }

        provide.value "$tgTemplate", mockTgTemplate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgTemplate()

            return null

    createDirective = () ->
        elm = compile(template)(scope)

        return elm

    beforeEach ->
        module "taigaUserTimeline"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "attachment image template", () ->
        scope.attachment =  Immutable.fromJS({
            url: "path/path/file.jpg"
        })

        mockTgTemplate.get
            .withArgs("user-timeline/user-timeline-attachment/user-timeline-attachment-image.html")
            .returns("<div id='image'></div>")

        elm = createDirective()

        expect(elm.find('#image')).to.have.length(1)

    it "attachment file template", () ->
        scope.attachment =  Immutable.fromJS({
            url: "path/path/file.pdf"
        })

        mockTgTemplate.get
            .withArgs("user-timeline/user-timeline-attachment/user-timeline-attachment.html")
            .returns("<div id='file'></div>")

        elm = createDirective()

        expect(elm.find('#file')).to.have.length(1)
