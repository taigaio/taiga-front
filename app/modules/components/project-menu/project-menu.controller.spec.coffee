###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "ProjectMenu", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockProjectService = ->
        mocks.projectService = {}

        $provide.value("tgProjectService", mocks.projectService)

    _mockLightboxFactory = ->
        mocks.lightboxFactory = {
            create: sinon.spy()
        }

        $provide.value("tgLightboxFactory", mocks.lightboxFactory)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockProjectService()
            _mockLightboxFactory()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "open search lightbox", () ->
        ctrl = $controller("ProjectMenu")
        ctrl.search()

        expectation = mocks.lightboxFactory.create.calledWithExactly("tg-search-box", {
            "class": "lightbox lightbox-search"
        })

        expect(expectation).to.be.true

    describe "show menu", ->
        it "project filled", () ->
            project = Immutable.fromJS({})

            mocks.projectService.project = project
            mocks.projectService.sectionsBreadcrumb = Immutable.List()

            ctrl = $controller("ProjectMenu")

            ctrl.show()

            expect(ctrl.project).to.be.equal(project)

        it "videoconference url", () ->
            project = Immutable.fromJS({
                "videoconferences": "whereby-com",
                "videoconferences_extra_data": "123",
                "slug": "project-slug"
            })

            mocks.projectService.project = project
            mocks.projectService.sectionsBreadcrumb = Immutable.List()

            ctrl = $controller("ProjectMenu")

            ctrl.show()

            url = "https://whereby.com/project-slug-123"

            expect(ctrl.project.get("videoconferenceUrl")).to.be.equal(url)

        describe "menu permissions", () ->
            it "all options disable", () ->
                project = Immutable.fromJS({})

                mocks.projectService.project = project
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                menu = ctrl.menu.toJS()

                expect(menu).to.be.eql({
                    epics: false,
                    backlog: false,
                    kanban: false,
                    issues: false,
                    wiki: false
                })

            it "all options enabled", () ->
                project = Immutable.fromJS({
                    is_epics_activated: true,
                    is_backlog_activated: true,
                    is_kanban_activated: true,
                    is_issues_activated: true,
                    is_wiki_activated: true,
                    my_permissions: ["view_epics", "view_us", "view_issues", "view_wiki_pages"]
                })

                mocks.projectService.project = project
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                menu = ctrl.menu.toJS()

                expect(menu).to.be.eql({
                    epics: true,
                    backlog: true,
                    kanban: true,
                    issues: true,
                    wiki: true
                })

            it "all options disabled because the user doesn't have permissions", () ->
                project = Immutable.fromJS({
                    is_epics_activated: true,
                    is_backlog_activated: true,
                    is_kanban_activated: true,
                    is_issues_activated: true,
                    is_wiki_activated: true,
                    my_permissions: []
                })

                mocks.projectService.project = project
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                menu = ctrl.menu.toJS()

                expect(menu).to.be.eql({
                    epics: false,
                    backlog: false,
                    kanban: false,
                    issues: false,
                    wiki: false
                })

        describe "menu active", () ->
            it "backlog", () ->
                project = Immutable.fromJS({})

                mocks.projectService.project = project
                mocks.projectService.section = "backlog"
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("backlog")

            it "backlog-kanban without parent", () ->
                project = Immutable.fromJS({})

                mocks.projectService.project = project
                mocks.projectService.section = "backlog-kanban"
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("backlog-kanban")

            it "backlog-kanban when only kanban is enabled", () ->
                project = Immutable.fromJS({
                    is_kanban_activated: true,
                    my_permissions: []
                })

                mocks.projectService.project = project
                mocks.projectService.section = "backlog-kanban"
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("kanban")

            it "backlog-kanban when only backlog is enabled", () ->
                project = Immutable.fromJS({
                    is_backlog_activated: true,
                    my_permissions: []
                })

                mocks.projectService.project = project
                mocks.projectService.section = "backlog-kanban"
                mocks.projectService.sectionsBreadcrumb = Immutable.List()

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("backlog")

            it "backlog-kanban when is child of kanban", () ->
                project = Immutable.fromJS({})

                mocks.projectService.project = project
                mocks.projectService.section = "backlog-kanban"
                mocks.projectService.sectionsBreadcrumb = Immutable.List.of("oo", "backlog", "kanban")

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("kanban")

            it "backlog-kanban when is child of backlog", () ->
                project = Immutable.fromJS({})

                mocks.projectService.project = project
                mocks.projectService.section = "backlog-kanban"
                mocks.projectService.sectionsBreadcrumb = Immutable.List.of("kanban", "oo", "backlog")

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("backlog")


            it "backlog-kanban when kanban is not in the breadcrumb", () ->
                project = Immutable.fromJS({})

                mocks.projectService.project = project
                mocks.projectService.section = "backlog-kanban"
                mocks.projectService.sectionsBreadcrumb = Immutable.List.of("oo", "backlog")

                ctrl = $controller("ProjectMenu")

                ctrl.show()

                expect(ctrl.active).to.be.equal("backlog")
