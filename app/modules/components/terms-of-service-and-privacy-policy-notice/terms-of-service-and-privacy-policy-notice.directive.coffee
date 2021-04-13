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
