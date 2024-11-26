###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

mixOf = @.taiga.mixOf
toggleText = @.taiga.toggleText
scopeDefer = @.taiga.scopeDefer
bindOnce = @.taiga.bindOnce
groupBy = @.taiga.groupBy
timeout = @.taiga.timeout

module = angular.module("taigaTaskboard")

#############################################################################
## Sprint burndown chart directive
#############################################################################

SprintChartDirective = ($translate)->
    redrawChart = (element, dataToDraw) ->
        width = element.width()
        element.height(240)

        days = _.map(dataToDraw, (x) -> moment.utc(x.day))

        data = []
        data.unshift({
            data: _.zip(days, _.map(dataToDraw, (d) -> d.open_points))
            lines:
                fillColor : "rgba(147,196,0,0.2)"
        })
        data.unshift({
            data: _.zip(days, _.map(dataToDraw, (d) -> d.optimal_points))
            lines:
                fillColor : "rgba(200,201,196,0.2)"
        })

        options =
            grid:
                borderWidth: { top: 0, right: 1, left:0, bottom: 0 }
                borderColor: "#D8DEE9"
                color: "#D8DEE9"
                hoverable: true
                margin: { top: 0, right: 30, left: 5, bottom: 5 }
            xaxis:
                tickSize: [1, "day"]
                min: days[0]
                max: _.last(days)
                mode: "time"
                daysNames: days
                axisLabel: $translate.instant("TASKBOARD.CHARTS.XAXIS_LABEL")
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 12
                axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif'
                axisLabelPadding: 5
            yaxis:
                min: 0
                axisLabel: $translate.instant("TASKBOARD.CHARTS.YAXIS_LABEL")
                axisLabelUseCanvas: true
                axisLabelFontSizePixels: 12
                axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif'
                axisLabelPadding: 5
            series:
                shadowSize: 0
                lines:
                    show: true
                    fill: true
                points:
                    show: true
                    fill: true
                    radius: 4
                    lineWidth: 2
            colors: [
                "rgba(216,222,233,1)"
                "rgba(168,228,64,1)"
            ]
            tooltip: true
            tooltipOpts:
                content: (label, xval, yval, flotItem) ->
                    formattedDate = moment(xval).format($translate.instant("TASKBOARD.CHARTS.DATE"))
                    roundedValue = Math.round(yval * 10) / 10

                    if flotItem.seriesIndex == 1
                        return $translate.instant("TASKBOARD.CHARTS.REAL", {
                            formattedDate: formattedDate,
                            roundedValue: roundedValue
                        })

                    else
                        return $translate.instant("TASKBOARD.CHARTS.OPTIMAL", {
                            formattedDate: formattedDate,
                            roundedValue: roundedValue
                        })

        element.empty()
        element.plot(data, options).data("plot")

    link = ($scope, $el, $attrs) ->
        element = angular.element($el)

        $scope.$on "resize", ->
            redrawChart(element, $scope.stats.days) if $scope.stats

        $scope.$on "taskboard:graph:toggle-visibility", ->
            $el.parent().toggleClass('open')

            # fix chart overflow
            timeout(100, ->
                redrawChart(element, $scope.stats.days) if $scope.stats
            )

        $scope.$watch 'stats', (value) ->
            if not $scope.stats?
                return
            redrawChart(element, $scope.stats.days)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgSprintChart", ["$translate", SprintChartDirective])
