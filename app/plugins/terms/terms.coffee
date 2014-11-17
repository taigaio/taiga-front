###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: plugins/terms/terms.coffee
###

taiga = @.taiga

module = angular.module("taigaPlugins", ["ngRoute"])

template = _.template("""
<p class="register-text">
    <span>By clicking "Sign up", you agree to our <br /></span>
    <a href="<%= termsUrl %>" title="See terms of service" target="_blank"> terms of service</a>
    <span> and</span>
    <a href="<%= privacyUrl %>" title="See privacy policy" target="_blank"> privacy policy.</a>
</p>""")


TermsNoticeDirective = ($config) ->
    privacyPolicyUrl = $config.get("privacyPolicyUrl")
    termsOfServiceUrl = $config.get("termsOfServiceUrl")

    templateFn = ->
        if not (privacyPolicyUrl and termsOfServiceUrl)
            return ""

        ctx = {termsUrl: termsOfServiceUrl, privacyUrl: privacyPolicyUrl}
        return template(ctx)

    return {
        scope: {}
        restrict: "AE"
        template: templateFn
    }


module.directive("tgTermsNotice", ["$tgConfig", TermsNoticeDirective])
