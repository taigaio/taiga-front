###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

module = angular.module("taigaIssues")

AiAnalysisModalDirective = ($compile) ->
    link = ($scope, $el, $attrs) ->
        $scope.vm = {
            showModal: false
            results: []
            closeModal: () ->
                $scope.vm.showModal = false
                $scope.$apply() if not $scope.$$phase
        }
        
        $scope.$on "aianalysis:show", (event, data) ->
            $scope.vm.results = data.results
            $scope.vm.showModal = true
            $scope.$apply() if not $scope.$$phase
    
    return {
        restrict: "E"
        templateUrl: "issue/ai-analysis-modal.html"
        link: link
    }

AiAnalysisModalDirective.$inject = [
    "$compile"
]

module.directive("tgAiAnalysisModal", AiAnalysisModalDirective)
