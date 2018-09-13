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
# File: modules/issues/lightboxes.coffee
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

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgLbCreateBulkIssues", ["$tgRepo", "$tgResources", "$tgConfirm", "$rootScope", "$tgLoading",
                                          "lightboxService", "$tgModel", CreateBulkIssuesDirective])
