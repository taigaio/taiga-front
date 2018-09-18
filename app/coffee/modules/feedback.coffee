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
# File: modules/feedback.coffee
###

taiga = @.taiga

groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
mixOf = @.taiga.mixOf
debounce = @.taiga.debounce
trim = @.taiga.trim

module = angular.module("taigaFeedback", [])

FeedbackDirective = ($lightboxService, $repo, $confirm, $loading, feedbackService)->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley()

        submit = debounce 2000, (event) =>
            event.preventDefault()

            if not form.validate()
                return

            currentLoading = $loading()
                .target(submitButton)
                .start()

            promise = $repo.create("feedback", $scope.feedback)

            promise.then (data) ->
                currentLoading.finish()
                $lightboxService.close($el)
                $confirm.notify("success", "\\o/ we'll be happy to read your")

            promise.then null, ->
                currentLoading.finish()
                $confirm.notify("error")

        submitButton = $el.find(".submit-button")

        $el.on "submit", "form", submit

        openLightbox = ->
            $scope.feedback = {}
            $lightboxService.open($el)
            $el.find("textarea").focus()

        $scope.$on "$destroy", ->
            $el.off()

        openLightbox()

    directive = {
        link: link,
        templateUrl: "common/lightbox-feedback.html"
        scope: {}
    }

    return directive

module.directive("tgLbFeedback", ["lightboxService", "$tgRepo", "$tgConfirm",
    "$tgLoading", "tgFeedbackService", FeedbackDirective])
