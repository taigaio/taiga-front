###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class FeedbackService extends taiga.Service
    @.$inject = ["tgLightboxFactory"]

    constructor: (@lightboxFactory) ->

    sendFeedback: ->
        @lightboxFactory.create("tg-lb-feedback", {
            "class": "lightbox lightbox-feedback lightbox-generic-form"
        })

angular.module("taigaFeedback").service("tgFeedbackService", FeedbackService)
