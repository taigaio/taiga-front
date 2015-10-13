joyRides = {
    dashboard: () ->
        return [
            {
                element: '.home-project-list',
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
            },
            {
                element: '.project-list .see-more-projects-btn',
                position: 'bottom',
                joyride: {
                    title: @translate.instant('JOYRIDE.DASHBOARD.STEP4.TITLE')
                    text: [
                        @translate.instant('JOYRIDE.DASHBOARD.STEP4.TEXT1'),
                        @translate.instant('JOYRIDE.DASHBOARD.STEP4.TEXT2')
                    ]
                }
            }
        ]

    backlog: () ->
        return [
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
            },
            {
                element: '.new-us',
                position: 'rigth',
                joyride: {
                    title: @translate.instant('JOYRIDE.BACKLOG.STEP4.TITLE')
                    text: @translate.instant('JOYRIDE.BACKLOG.STEP4.TEXT')
                }
            }
        ]

     kanban: () ->
        return [
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
            },
            {
                element: '.icon-plus',
                position: 'bottom',
                joyride: {
                    title: @translate.instant('JOYRIDE.KANBAN.STEP3.TITLE')
                    text: [
                        @translate.instant('JOYRIDE.KANBAN.STEP3.TEXT1'),
                        @translate.instant('JOYRIDE.KANBAN.STEP3.TEXT2'),
                    ]
                }
            }
        ]
}


class JoyRideService extends taiga.Service
    @.$inject = [
        '$translate'
    ]

    constructor: (@translate) ->

    get: (name) ->
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
