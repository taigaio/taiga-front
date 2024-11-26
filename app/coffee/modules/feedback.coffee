###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
