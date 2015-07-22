var utils = require('../utils');
var backlogHelper = require('../helpers').backlog;
var taskboardHelper = require('../helpers').taskboard;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('taskboard', function() {
    before(async function() {
        browser.get('http://localhost:9001/project/project-0/backlog');
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
            formFields.blockedNote = 'blocked note';

            createTaskLightbox.subject().sendKeys(formFields.subject);
            createTaskLightbox.description().sendKeys(formFields.description);

            createTaskLightbox.tags().sendKeys('aaa');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createTaskLightbox.tags().sendKeys('bbb');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createTaskLightbox.blocked().click();
            createTaskLightbox.blockedNote().sendKeys(formFields.blockedNote);

            utils.common.takeScreenshot('taskboard', 'create-task-filled');
        });

        it('send form', async function() {
            createTaskLightbox.submit();

            await utils.lightbox.close(createTaskLightbox.el);

            let task = taskboardHelper.getBoxTasks(0, 0).last();
            let taskSubject = task.$('.task-name').getText();

            expect(taskSubject).to.be.eventually.equal(formFields.subject);
        });
    });

    describe('bulk create', function() {
        let bulkCreateTaskLightbox;

        before(async function() {
            taskboardHelper.openBulkTaskLb(0);

            bulkCreateTaskLightbox = taskboardHelper.getBulkCreateTask();

            await bulkCreateTaskLightbox.waitOpen();
        });

        it('fill form', function() {
            bulkCreateTaskLightbox.textarea().sendKeys('aaa');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            bulkCreateTaskLightbox.textarea().sendKeys('bbb');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();
        });

        it('send form', async function() {
            let taskCount = await taskboardHelper.getBoxTasks(0, 0).count();

            bulkCreateTaskLightbox.submit();

            await utils.lightbox.close(bulkCreateTaskLightbox.el);

            let newTaskCount = await taskboardHelper.getBoxTasks(0, 0).count();

            expect(newTaskCount).to.be.equal(taskCount + 2);
        });
    });

    describe('folds', function() {
        it('fold row', async function() {
            taskboardHelper.foldRow(0);

            utils.common.takeScreenshot('taskboard', 'fold-row');

            let rowsFold = await $$('.row-fold').count();

            expect(rowsFold).to.be.equal(1);
        });

        it('unfold row', async function() {
            taskboardHelper.unFoldRow(0);

            let rowsFold = await $$('.row-fold').count();

            expect(rowsFold).to.be.equal(0);
        });

        it('fold column', async function() {
            taskboardHelper.foldColumn(0);

            utils.common.takeScreenshot('taskboard', 'fold-column');

            let columnFold = await $$('.column-fold').count();

            expect(columnFold).to.be.above(1);
        });

        it('unfold column', async function() {
            taskboardHelper.unFoldColumn(0);

            let columnFold = await $$('.column-fold').count();

            expect(columnFold).to.be.equal(0);
        });

        it('fold row and column', async function() {
            taskboardHelper.foldRow(0);
            taskboardHelper.foldColumn(0);

            utils.common.takeScreenshot('taskboard', 'fold-column-row');

            let rowsFold = await $$('.row-fold').count();
            let columnFold = await $$('.column-fold').count();

            expect(rowsFold).to.be.equal(1);
            expect(columnFold).to.be.above(1);
        });

        it('unfold row and column', async function() {
            taskboardHelper.unFoldRow(0);
            taskboardHelper.unFoldColumn(0);

            let rowsFold = await $$('.row-fold').count();
            let columnFold = await $$('.column-fold').count();

            expect(rowsFold).to.be.equal(0);
            expect(columnFold).to.be.equal(0);
        });
    });
});
