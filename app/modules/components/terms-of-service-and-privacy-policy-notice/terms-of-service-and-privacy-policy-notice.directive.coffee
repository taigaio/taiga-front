###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

TermsOfServiceAndPrivacyPolicyNoticeDirective = ($config) ->
    link = (scope, el, attrs) ->
        scope.privacyPolicyUrl = $config.get("privacyPolicyUrl")
        scope.termsOfServiceUrl = $config.get("termsOfServiceUrl")
        scope.target = false

        if !scope.privacyPolicyUrl || !scope.termsOfServiceUrl
            scope.target = true

        el.on "change", "input[name='accepted_terms']", (event) ->
            target = angular.element(event.currentTarget)
            scope.target = target.is(":checked")
            scope.$apply()

    return {
        restrict: "AE",
        link: link,
        scope: {
            target: "="
        }
        templateUrl: "components/terms-of-service-and-privacy-policy-notice/terms-of-service-and-privacy-policy-notice.html"
    }

angular.module("taigaComponents")
    .directive("tgTermsOfServiceAndPrivacyPolicyNotice", [
        "$tgConfig",
        TermsOfServiceAndPrivacyPolicyNoticeDirective
    ])
