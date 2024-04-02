###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

#############################################################################
## Animated Counter
#############################################################################
AnimatedCounter = () ->
    template = """
        <div
            ng-class="{'wip-amount': data.wip, 'limit-over': data.count > data.wip}"
            class="animated-counter-inner">
            <div class="counter-translator">
                <div class="result">
                    <span class="current">{{ nextUp.current || 0 }}</span><span ng-if="nextUp.wip"> / {{ nextUp.wip }}</span>
                </div>
                <div class="result">
                    <span class="current">{{ renderCount.current || 0 }}</span><span ng-if="renderCount.wip"> / {{ renderCount.wip }}</span>
                </div>
                <div class="result">
                    <span class="current">{{ nextDown.current || 0 }}</span><span ng-if="nextDown.wip"> / {{ nextDown.wip }}</span>
                </div>
            </div>
        </div>
    """

    link = ($scope, $el, $attrs) ->
        transitionEnd = (event) ->
            $scope.$evalAsync () =>
                if $scope.nextUp != undefined
                    $scope.renderCount = $scope.nextUp
                else
                    $scope.renderCount = $scope.nextDown

                $(counter).removeClass('inc dec')

        counter = $el.find('.counter-translator')
        counter.on('transitionend', transitionEnd)
        initialLoad = false
        lastCount = undefined

        unwatch = $scope.$on 'kanban:userstories:loaded', () ->
            initialLoad = true
            unwatch()

        renderData = (data) ->
            getCounter = (num) =>
                return {
                    current: num,
                    wip: data.wip,
                }

            $scope.nextUp = undefined
            $scope.nextDown = undefined

            if !$scope.data || $scope.data.count == undefined
                lastCount = 0
                $scope.renderCount = getCounter(lastCount)
                return
            else if lastCount == $scope.data.count
                return
            # initialLoad, wait empty @.queue to animate preventing the animation on load
            else if !initialLoad || lastCount == undefined
                lastCount = $scope.data.count
                $scope.renderCount = getCounter(lastCount)
                return

            if $scope.data.count > lastCount
                lastCount = $scope.data.count
                $scope.nextUp = getCounter($scope.data.count)
            else if $scope.data.count < lastCount
                lastCount = $scope.data.count
                $scope.nextDown = getCounter($scope.data.count)

            if $scope.nextUp != undefined || $scope.nextDown != undefined
                counter.removeClass('inc dec')

                $scope.$evalAsync () =>
                    if $scope.nextUp != undefined
                        counter.addClass('inc')
                    else if $scope.nextDown != undefined
                        counter.addClass('dec')

        $scope.$watch 'disabled', (disabled) ->
            if $scope.disabled
                return

            renderData($scope.data)

        $scope.$watch 'data', (data) ->
            if $scope.disabled
                return

            renderData(data)

        $scope.$on "$destroy", ->
            $el.off()
            counter.off()

    return {
        link: link,
        template: template,
        scope: {
            data: '<',
            disabled: '<'
        },
    }

angular.module('taigaComponents').directive("tgAnimatedCounter", [AnimatedCounter])
