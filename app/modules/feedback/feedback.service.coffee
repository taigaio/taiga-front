###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class FeedbackService extends taiga.Service
    @.$inject = ["tgLightboxFactory"]

    constructor: (@lightboxFactory) ->

    sendFeedback: ->
        @lightboxFactory.create("tg-lb-feedback", {
            "class": "lightbox lightbox-feedback lightbox-generic-form"
        })

angular.module("taigaFeedback").service("tgFeedbackService", FeedbackService)
