###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

module = angular.module("taigaIssues")

class AiAnalysisLightboxController
    @.$inject = [
        "$scope",
        "$rootScope",
        "tgLightboxFactory"
    ]

    constructor: (@scope, @rootscope, @lightboxFactory) ->
        @.results = []
        
        # 监听显示 AI 分析结果的事件
        @rootscope.$on "aianalysis:show", (event, data) =>
            @.results = data.results
            @scope.$apply() if not @scope.$$phase

    close: ->
        @lightboxFactory.close("tg-lb-ai-analysis")

module.controller("AiAnalysisLightboxCtrl", AiAnalysisLightboxController)

AiAnalysisLightboxDirective = () ->
    return {
        templateUrl: "issue/ai-analysis-lightbox.html",
        controller: "AiAnalysisLightboxCtrl",
        controllerAs: "ctrl",
        bindToController: true,
        scope: {}
    }

module.directive("tgLbAiAnalysis", AiAnalysisLightboxDirective)
