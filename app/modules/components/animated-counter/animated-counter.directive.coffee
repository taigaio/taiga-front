#############################################################################
## Animated Counter
#############################################################################
AnimatedCounter = () ->
    template = """
        <div
            ng-class="{'wip-amount': data.wip, 'limit-over': data.count > data.wip}"
            class="animated-counter-inner">
            <div class="counter-translator">
                <span>{{ nextUp }}</span>
                <span>{{ renderCount }}</span>
                <span>{{ nextDown }}</span>
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

        lastCount = undefined

        $scope.$watch 'data', (data) ->
            getCounter = (num) =>
                if data.wip
                    return num + '/' + data.wip
                return num

            $scope.nextUp = undefined
            $scope.nextDown = undefined

            if !$scope.data || $scope.data.count == undefined
                lastCount = 0
                $scope.renderCount = getCounter(lastCount)
                return
            else if lastCount == $scope.data.count
                return
            # $scope.initialLoad, wait empty @.queue to animate preventing the animation on load
            else if !$scope.initialLoad || lastCount == undefined
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

        $scope.$on "$destroy", ->
            $el.off()
            counter.off()

    return {
        link: link,
        template: template,
        scope: {
            data: '<',
            initialLoad: '<'
        },
    }

angular.module('taigaComponents').directive("tgAnimatedCounter", [AnimatedCounter])
