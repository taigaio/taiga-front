var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Public', async function(){
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-3/admin/project-profile/details');

        await utils.common.waitLoader();

        $$('.privacy-settings input').get(0).click();

        $('button[type="submit"]').click();

        await utils.notifications.success.open();
        await utils.notifications.success.close();

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

    it('us detail', function() {
        browser.get(browser.params.glob.host + 'project/project-3/us/81');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'us-detail');
    });

    it('issue detail', function() {
        browser.get(browser.params.glob.host + 'project/project-3/issue/95');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'issue-detail');
    });

    it('task detail', function() {
        browser.get(browser.params.glob.host + 'project/project-3/task/2');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'task-detail');
    });

    it('team', function() {
        browser.get(browser.params.glob.host + 'project/project-5/team');

        utils.common.waitLoader();

        utils.common.takeScreenshot('public', 'us-detail');
    });
});
