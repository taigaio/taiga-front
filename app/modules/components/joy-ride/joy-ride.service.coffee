###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/joy-ride/joy-ride.service.coffee
###

class JoyRideService extends taiga.Service
    @.$inject = [
        '$translate',
        'tgCheckPermissionsService'
    ]

    constructor: (@translate, @checkPermissionsService) ->

    getConfig: () ->
      return {
          dashboard: () =>
              steps = [
                  {
                      element: '.project-list > section:not(.ng-hide)',
                      position: 'left',
                      joyride: {
                          title: @translate.instant('JOYRIDE.DASHBOARD.STEP1.TITLE'),
                          text: @translate.instant('JOYRIDE.DASHBOARD.STEP1.TEXT')
                      }
                  },
                  {
                      element: '.working-on-container',
                      position: 'right',
                      joyride: {
                          title: @translate.instant('JOYRIDE.DASHBOARD.STEP2.TITLE'),
                          text: @translate.instant('JOYRIDE.DASHBOARD.STEP2.TEXT')
                      }
                  },
                  {
                      element: '.watching-container',
                      position: 'right',
                      joyride: {
                          title: @translate.instant('JOYRIDE.DASHBOARD.STEP3.TITLE')
                          text: [
                              @translate.instant('JOYRIDE.DASHBOARD.STEP3.TEXT1'),
                              @translate.instant('JOYRIDE.DASHBOARD.STEP3.TEXT2')
                          ]
                      }
                  }
              ]

              if !$('.project-list .create-project-button').is(':hidden')
                  steps.push({
                      element: '.project-list .create-project-button',
                      position: 'bottom',
                      joyride: {
                          title: @translate.instant('JOYRIDE.DASHBOARD.STEP4.TITLE')
                          text: [
                              @translate.instant('JOYRIDE.DASHBOARD.STEP4.TEXT1'),
                              @translate.instant('JOYRIDE.DASHBOARD.STEP4.TEXT2')
                          ]
                      }
                  })

              return steps

          backlog: () =>
              steps = [
                  {
                      element: '.summary',
                      position: 'bottom',
                      joyride: {
                          title: @translate.instant('JOYRIDE.BACKLOG.STEP1.TITLE')
                          text: [
                              @translate.instant('JOYRIDE.BACKLOG.STEP1.TEXT1'),
                              @translate.instant('JOYRIDE.BACKLOG.STEP1.TEXT2')
                          ]
                      }
                  },
                  {
                      element: '.backlog-table-empty',
                      position: 'bottom',
                      joyride: {
                          title: @translate.instant('JOYRIDE.BACKLOG.STEP2.TITLE')
                          text: @translate.instant('JOYRIDE.BACKLOG.STEP2.TEXT')
                      }
                  },
                  {
                      element: '.sprints',
                      position: 'left',
                      joyride: {
                          title: @translate.instant('JOYRIDE.BACKLOG.STEP3.TITLE')
                          text: @translate.instant('JOYRIDE.BACKLOG.STEP3.TEXT')
                      }
                  }
              ]

              if @checkPermissionsService.check('add_us')
                  steps.push({
                      element: '.new-us',
                      position: 'rigth',
                      joyride: {
                          title: @translate.instant('JOYRIDE.BACKLOG.STEP4.TITLE')
                          text: @translate.instant('JOYRIDE.BACKLOG.STEP4.TEXT')
                      }
                  })

              return steps

           kanban: () =>
              steps = [
                  {
                      element: '.kanban-table-inner',
                      position: 'bottom',
                      joyride: {
                          title: @translate.instant('JOYRIDE.KANBAN.STEP1.TITLE')
                          text: @translate.instant('JOYRIDE.KANBAN.STEP1.TEXT')
                      }
                  },
                  {
                      element: '.card-placeholder',
                      position: 'right',
                      joyride: {
                          title: @translate.instant('JOYRIDE.KANBAN.STEP2.TITLE')
                          text: @translate.instant('JOYRIDE.KANBAN.STEP2.TEXT')
                      }
                  }
              ]

              if @checkPermissionsService.check('add_us')
                  steps.push({
                        element: '.add-action',
                        position: 'bottom',
                        joyride: {
                            title: @translate.instant('JOYRIDE.KANBAN.STEP3.TITLE')
                            text: [
                                @translate.instant('JOYRIDE.KANBAN.STEP3.TEXT1'),
                                @translate.instant('JOYRIDE.KANBAN.STEP3.TEXT2'),
                            ]
                        }
                    })

              return steps
      }

    get: (name) ->
        joyRides = @.getConfig()
        joyRide = joyRides[name].call(this)

        return _.map joyRide, (item) ->
            html = ""

            if item.joyride.title
                html += "<h3>#{item.joyride.title}</h3>"

            if _.isArray(item.joyride.text)
                _.forEach item.joyride.text, (text) ->
                    html += "<p>#{text}</p>"
            else
                html += "<p>#{item.joyride.text}</p>"

            item.intro = html

            return item

angular.module("taigaComponents").service("tgJoyRideService", JoyRideService)
