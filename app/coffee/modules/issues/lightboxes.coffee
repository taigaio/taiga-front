###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce
trim = @.taiga.trim

module = angular.module("taigaIssues")

#############################################################################
## Issue Bulk Create Lightbox Directive
#############################################################################

CreateBulkIssuesDirective = ($repo, $rs, $confirm, $rootscope, $loading, lightboxService, $model) ->
    link = ($scope, $el, attrs) ->
        form = null

        $scope.$on "issueform:bulk", (ctx, projectId, milestoneId, status)->
            form.reset() if form

            lightboxService.open($el)
            $scope.new = {
                projectId: projectId,
                milestoneId: milestoneId,
                bulk: ""
            }

        submit = debounce 2000, (event) ->
            event.preventDefault()

            form = $el.find("form").checksley()
            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            if currentLoading.isLoading()
                return

            data = $scope.new.bulk
            projectId = $scope.new.projectId
            milestoneId = $scope.new.milestoneId

            promise = $rs.issues.bulkCreate(projectId, milestoneId, data)
            promise.then (result) ->
                result =  _.map(result.data, (x) -> $model.make_model('issues', x))
                currentLoading.finish()
                $rootscope.$broadcast("issueform:new:success", result)
                lightboxService.close($el)
                $confirm.notify("success")

            promise.then null, ->
                currentLoading.finish()
                $confirm.notify("error")

        submitButton = $el.find("button[type='submit']")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateBulkIssues", ["$tgRepo", "$tgResources", "$tgConfirm", "$rootScope", "$tgLoading",
                                          "lightboxService", "$tgModel", CreateBulkIssuesDirective])
