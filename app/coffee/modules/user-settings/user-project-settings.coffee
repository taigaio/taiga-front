###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
mixOf = @.taiga.mixOf
bindOnce = @.taiga.bindOnce

module = angular.module("taigaUserSettings")


#############################################################################
## Custom Homepage Controller
#############################################################################

class UserProjectSettingsController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$rootScope"
        "$scope"
        "$tgSections"
        "$tgResources"
        "$tgRepo"
        "$tgConfirm"
         "tgCurrentUserService"
    ]

    constructor: (@rootScope, @scope, @tgSections, @rs, @repo, @confirm, @currentUserService) ->
        @scope.sections = @tgSections.list()

        promise = @.loadInitialData()
        promise.then null, @.onInitialDataError.bind(@)

    loadInitialData: ->
        return @rs.userProjectSettings.list().then (userProjectSettings) =>
            @scope.userProjectSettings = userProjectSettings

    updateCustomHomePage: (projectSettings) ->
        onSuccess = =>
            @currentUserService.loadProjects()
            @rootScope.$broadcast("dropdown-project-list:updated")
            @confirm.notify("success")

        onError = =>
            @confirm.notify("error")

        @repo.save(projectSettings).then(onSuccess, onError)

    filteredSections: (projectSettings) ->
        return _.filter @scope.sections, (section) ->
            section.id in projectSettings.allowed_sections


module.controller("UserProjectSettingsController", UserProjectSettingsController)
