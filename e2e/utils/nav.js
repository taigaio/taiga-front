var helper = module.exports;

var common = require('./common');

var actions = {
    project: function(index) {
        browser.actions().mouseMove($('div[tg-dropdown-project-list]')).perform();

        let project = $$('div[tg-dropdown-project-list] li a').first();

        common.link(project);

        common.waitLoader();
    },
    issues: function(index) {
        common.link($('#nav-issues a'));

        common.waitLoader();
    },
    issue: function(index) {
        let issue = $$('section.issues-table .row.table-main .subject a').get(index);

        common.link(issue);

        common.waitLoader();
    },
    backlog: function() {
        common.link($('#nav-backlog a'));

        common.waitLoader();
    },
    us: function(index) {
        let us = $$('.user-story-name>a').get(index);

        common.link(us);

        common.waitLoader();
    },
    taskboard: function(index) {
        let link = $$('.sprints .button-gray').get(index);

        common.link(link);

        common.waitLoader();
    },
    task: function(index) {
        common.link($$('div[tg-taskboard-task] a.task-name').get(index));

        common.waitLoader();
    }
};

var nav = {
    actions: [],
    project: function(index) {
        this.actions.push(actions.project.bind(null, index));
        return nav;
    },
    issues: function() {
        this.actions.push(actions.issues);
        return nav;
    },
    issue: function(index) {
        this.actions.push(actions.issue.bind(null, index));
        return nav;
    },
    backlog: function(index) {
        this.actions.push(actions.backlog.bind(null, index));
        return nav;
    },
    us: function(index) {
        this.actions.push(actions.us.bind(null, index));
        return nav;
    },
    taskboard: function(index) {
        this.actions.push(actions.taskboard.bind(null, index));
        return nav;
    },
    task: function(index) {
        this.actions.push(actions.task.bind(null, index));
        return nav;
    },
    go: function() {
        for (let action of this.actions) {
            action();
        }
    }
};

helper.init = function() {
    return nav;
};
