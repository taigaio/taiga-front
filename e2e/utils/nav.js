/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var helper = module.exports;

var common = require('./common');

var actions = {
    project: async function(index) {
        browser.actions().mouseMove($('div[tg-dropdown-project-list]')).perform();

        let project = null;

        if (typeof index === 'string' || index instanceof String) {
            project = $('div[tg-dropdown-project-list]').element(by.cssContainingText('li a', index));
        } else {
            project = $$('div[tg-dropdown-project-list] li a').get(index);
        }

        let oldUrl = await browser.getCurrentUrl();

        await browser
            .actions()
            .mouseMove(project)
            .perform();

        let href = await common.waitHref(project);

        // we don't use click because in IE doesn't work
        browser.get(href);

        await browser.wait(async function() {
            let newUrl = await browser.getCurrentUrl();

            return oldUrl !== newUrl;
        }, 7000);

        return common.waitLoader();
    },
    issues: async function(index) {
        await common.link($('#nav-issues a'));

        return common.waitLoader();
    },
    issue: async function(index) {
        let issue = $$('section.issues-table .row.table-main .subject a').get(index);

        await common.link(issue);

        return common.waitLoader();
    },

    epics: async function() {
        await common.link($('#nav-epics a'));

        return common.waitLoader();
    },

    epic: async function(index) {
        let epic = $$('.e2e-epic-row .name a').get(index);

        await common.link(epic);

        return common.waitLoader();
    },

    backlog: async function() {
        await common.link($$('#nav-backlog a').first());

        return common.waitLoader();
    },
    us: async function(index) {
        let us = $$('.user-story-name>a').get(index);

        await common.link(us);

        return common.waitLoader();
    },
    home: function() {
        browser.get(browser.params.glob.host);
        return common.waitLoader();
    },
    admin: async function() {
        await common.link($('#nav-admin a'));

        return common.waitLoader();
    },
    taskboard: async function(index) {
        let link = $$('.sprints .button-gray').get(index);

        await common.link(link);

        return common.waitLoader();
    },
    task: async function(index) {
        let task = $$('tg-card .card-title a').get(index);

        await common.link(task);

        return common.waitLoader();
    },
    team: async function() {
        await common.link($('#nav-team a'));

        return common.waitLoader();
    }
};

var nav = {
    project: function(index) {
        this.actions.push(actions.project.bind(null, index));
        return this;
    },
    issues: function() {
        this.actions.push(actions.issues);
        return this;
    },
    issue: function(index) {
        this.actions.push(actions.issue.bind(null, index));
        return this;
    },
    epics: function(index) {
        this.actions.push(actions.epics.bind(null, index));
        return this;
    },
    epic: function(index) {
        this.actions.push(actions.epic.bind(null, index));
        return this;
    },
    backlog: function(index) {
        this.actions.push(actions.backlog.bind(null, index));
        return this;
    },
    us: function(index) {
        this.actions.push(actions.us.bind(null, index));
        return this;
    },
    home: function() {
        this.actions.push(actions.home.bind(null));
        return this;
    },
    admin: function() {
        this.actions.push(actions.admin.bind(null));
        return this;
    },
    taskboard: function(index) {
        this.actions.push(actions.taskboard.bind(null, index));
        return this;
    },
    task: function(index) {
        this.actions.push(actions.task.bind(null, index));
        return this;
    },
    team: function(index) {
        this.actions.push(actions.team.bind(null, index));
        return this;
    },
    go: function() {
        let promise = this.actions[0]();

        for (let i = 1; i < this.actions.length; i++) {
            promise = promise.then(this.actions[i]);
        }

        return promise;
    }
};

helper.init = function() {
    let newNav = Object.create(nav);
    newNav.actions = [];

    return newNav;
};
