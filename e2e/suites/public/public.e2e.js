/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Public', async function(){
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-3/admin/project-profile/details');

        await utils.common.waitLoader();

        $$('.project-privacy-settings label').get(0).click();

        $('button[type="submit"]').click();

        await utils.notifications.success.open();
        await utils.notifications.success.close();

        //We need this click on firefox, probably the mouse is in a previous input
        $('body').click();

        return utils.common.logout();
    });

    it('home', function() {
        browser.get(browser.params.glob.host + 'project/project-3/');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'home');
    });

    it('backlog', function() {
        browser.get(browser.params.glob.host + 'project/project-3/backlog');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'backog');
    });

    it('taskboard', function() {
        browser.get(browser.params.glob.host + 'project/project-3/backlog');

        utils.common.waitLoader();

        $$('.sprints .button-gray').get(0).click();
        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'taskboard');
    });

    it('kanban', function() {
        browser.get(browser.params.glob.host + 'project/project-3/kanban');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'kanban');
    });

    it('us detail', async function() {
        browser.get(browser.params.glob.host + 'project/project-3/backlog');

        await utils.common.waitLoader();

        await utils.nav
            .init()
            .us(0)
            .go();

        return utils.common.takeScreenshot('public', 'us-detailb');
    });

    it('issue detail', async function() {
        browser.get(browser.params.glob.host + 'project/project-3/issues');

        await utils.common.waitLoader();

        await utils.nav
            .init()
            .issue(0)
            .go();

        utils.common.takeScreenshot('public', 'issue-detail');
    });

    it('task detail', async function() {
        browser.get(browser.params.glob.host + 'project/project-3/backlog');

        await utils.common.waitLoader();

        await utils.nav
            .init()
            .taskboard(0)
            .task(0)
            .go();

        utils.common.takeScreenshot('public', 'task-detail');
    });

    it('team', function() {
        browser.get(browser.params.glob.host + 'project/project-3/team');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'us-detail');
    });
});
