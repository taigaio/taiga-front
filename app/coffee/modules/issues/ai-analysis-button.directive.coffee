###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

module = angular.module("taigaIssues")

AiAnalysisButtonDirective = ($translate, $confirm, tgAiAnalysisService) ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", (event) ->
            event.preventDefault()
            
            issues = $scope.$eval($attrs.issues)
            projectId = $scope.$eval($attrs.projectId)
            
            if not issues or issues.length == 0
                $confirm.notify("error", $translate.instant("ISSUES.AI_NO_ISSUES"))
                return
            
            loader = $confirm.loader($translate.instant("ISSUES.AI_ANALYSIS_LOADING"))
            loader.start()
            
            promise = tgAiAnalysisService.analyzeIssues(projectId, issues)
            
            promise.then (results) ->
                loader.stop()
                
                angular.element(".lightbox-generic-loading").removeClass("active")
                angular.element(".lightbox-generic-loading .overlay").removeClass("active")
                
                setTimeout ->
                    $scope.$root.$broadcast("aianalysis:show", {
                        results: results
                    })
                    $scope.$apply() if not $scope.$$phase
                , 200
            .catch (error) ->
                loader.stop()
                angular.element(".lightbox-generic-loading").removeClass("active")
                angular.element(".lightbox-generic-loading .overlay").removeClass("active")
                $confirm.notify("error", $translate.instant("ISSUES.AI_ANALYSIS_ERROR"))
        
        $scope.$on "$destroy", ->
            $el.off()
    
    return {
        restrict: "A"
        link: link
    }

AiAnalysisButtonDirective.$inject = [
    "$translate",
    "$tgConfirm",
    "tgAiAnalysisService"
]

module.directive("tgAiAnalysisButton", AiAnalysisButtonDirective)
