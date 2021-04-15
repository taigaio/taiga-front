###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

BlockedProjectExplanationDirective = () ->
    return {
        templateUrl: "projects/project/blocked-project-explanation.html"
    }

angular.module("taigaProjects").directive("tgBlockedProjectExplanation", BlockedProjectExplanationDirective)
