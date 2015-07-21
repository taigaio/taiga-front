var utils = require('../utils');
var backlogHelper = require('../helpers').backlog;
var taskboardHelper = require('../helpers').taskboard;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe.only('taskboard', function() {
    before(async function() {
        browser.get('http://localhost:9001/project/user7-project-example-0/backlog');
        await utils.common.waitLoader();

        let sprint = backlogHelper.sprints().get(0);

        sprint.$('.button-gray').click();

        await utils.common.waitLoader();

        utils.common.takeScreenshot('taskboard', 'taskboard');
    });

    describe('create task', function() {
        let createTaskLightbox = null;
        let formFields = {};

        before(async function() {
            taskboardHelper.openNewTaskLb(0);

            createTaskLightbox = taskboardHelper.getCreateTask();

            await createTaskLightbox.waitOpen();
        });

        it('capture screen', function() {
            utils.common.takeScreenshot('taskboard', 'create-task');
        });

        it('fill form', async function() {
            let date = Date.now();
            formFields.subject = 'test subject' + date;
            formFields.description = 'test description' + date;

            createTaskLightbox.subject().sendKeys(formFields.subject);
            createTaskLightbox.description().sendKeys(formFields.description);
        });

        it('send form', async function() {
            createTaskLightbox.submit();

            await utils.lightbox.close(createTaskLightbox.el);

            let task = taskboardHelper.getBoxTasks(0, 0).last();
            let taskSubject = task.$('.task-name').getText();

            expect(taskSubject).to.be.eventually.equal(formFields.subject);
        });
    });
});
