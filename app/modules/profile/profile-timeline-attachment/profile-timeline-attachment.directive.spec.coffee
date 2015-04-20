describe "profileTimelineAttachmentDirective", () ->
    element = scope = compile = provide = null
    mockTgTemplate = null
    template = "<div tg-profile-timeline-attachment='attachment'></div>"

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
        module "taigaProfile"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "attachment image template", () ->
        scope.attachment =  {
            url: "path/path/file.jpg"
        }

        mockTgTemplate.get
            .withArgs("profile/profile-timeline-attachment/profile-timeline-attachment-image.html")
            .returns("<div id='image'></div>")

        elm = createDirective()

        expect(elm.find('#image')).to.have.length(1)

    it "attachment file template", () ->
        scope.attachment =  {
            url: "path/path/file.pdf"
        }

        mockTgTemplate.get
            .withArgs("profile/profile-timeline-attachment/profile-timeline-attachment.html")
            .returns("<div id='file'></div>")

        elm = createDirective()

        expect(elm.find('#file')).to.have.length(1)
