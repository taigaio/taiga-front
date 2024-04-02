###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class CreateProjectController
    @.$inject = [
        "tgAppMetaService",
        "$translate",
        "tgProjectService",
        "$tgAuth",
        "tgLightboxFactory",
        "tgResources",
        "$tgConfig"
    ]

    constructor: (@appMetaService, @translate, @projectService, @authService, @lightboxFactory, @rs, @config) ->
        taiga.defineImmutableProperty @, "project", () => return @projectService.project

        @appMetaService.setfn @._setMeta.bind(this)

        @authService.refresh()

        @.displayScrumDesc = false
        @.dontAsk = false

        # If you want to prevent this lightbox from showing up you need to add the variable isSass and set it to true on the conf.json
        if !@config.get("isSaas")
            @rs.user.getUserStorage('dont_ask_premise_newsletter')
                .then (storageState) =>
                    @.dontAsk = storageState
                    @.displayOnPremise()
                .catch (storageError) =>
                    if storageError.status = 404
                        @rs.user.createUserStorage('dont_ask_premise_newsletter', false)
                        @.dontAsk = false
                        @.displayOnPremise()


    _setMeta: () ->
        return null if !@.project

        ctx = {projectName: @.project.get("name")}

        return {
            title: @translate.instant("PROJECT.PAGE_TITLE", ctx)
            description: @.project.get("description")
        }

    displayOnPremise: () ->
        if !@.dontAsk
            @lightboxFactory.create("tg-newsletter-email-lightbox", {
                "class": "lightbox newsletter-email"
            })

    displayHelp: (type, $event) ->
        $event.stopPropagation()
        $event.preventDefault()

        if type == 'scrum'
            @.displayScrumDesc = !@.displayScrumDesc
        if type == 'kanban'
            @.displayKanbanDesc = !@.displayKanbanDesc


angular.module("taigaProjects").controller("CreateProjectCtrl", CreateProjectController)
