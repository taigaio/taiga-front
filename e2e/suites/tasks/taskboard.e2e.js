/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var backlogHelper = require('../../helpers').backlog;
var taskboardHelper = require('../../helpers').taskboard;
var commonHelper = require('../../helpers').common;
var filterHelper = require('../../helpers/filters-helper');
var sharedFilters = require('../../shared/filters');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('taskboard', function() {
    before(async function() {
        await utils.nav
            .init()
            .project('Project Example 1')
            .backlog()
            .taskboard(0)
            .go();

        utils.common.takeScreenshot('taskboard', 'taskboard');
    });

    it('zoom', async function() {
        taskboardHelper.zoom(0);
        await browser.sleep(1000);
        utils.common.takeScreenshot('taskboard', 'zoom1');

        taskboardHelper.zoom(1);
        await browser.sleep(1000);
        utils.common.takeScreenshot('taskboard', 'zoom1');

        taskboardHelper.zoom(2);
        await browser.sleep(1000);
        utils.common.takeScreenshot('taskboard', 'zoom2');

        taskboardHelper.zoom(3);
        await browser.sleep(1000);
        utils.common.takeScreenshot('taskboard', 'zoom3');
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

            commonHelper.tags();

            await createTaskLightbox.blocked().click();
            await createTaskLightbox.blockedNote().sendKeys(formFields.blockedNote);

            utils.common.takeScreenshot('taskboard', 'create-task-filled');
        });

        it('send form', async function() {
            createTaskLightbox.submit();

            await utils.lightbox.close(createTaskLightbox.el);

            let tasks = taskboardHelper.getBoxTasks(0, 0);

            let tasksSubject = await $$('.e2e-title').getText();

            let findSubject = tasksSubject.indexOf(formFields.subject) !== -1;

            expect(findSubject).to.be.true;
        });
    });

    describe('edit task', function() {
        let createTaskLightbox = null;
        let formFields = {};

        before(async function() {
            taskboardHelper.editTask(0, 0, 0);

            createTaskLightbox = taskboardHelper.getCreateTask();

            await createTaskLightbox.waitOpen();
        });

        it('capture screen', function() {
            utils.common.takeScreenshot('taskboard', 'edit-task');
        });

        it('fill form', async function() {
            let date = Date.now();
            formFields.subject = 'test subject' + date;
            formFields.description = 'test description' + date;
            formFields.blockedNote = 'blocked note';

            createTaskLightbox.subject().sendKeys(formFields.subject);
            await createTaskLightbox.description().sendKeys(formFields.description);

            await utils.common.takeScreenshot('taskboard', 'edit-task-filled');

            // send form fail when all tests are launched
            await browser.sleep(1000);
        });

        it('send form', async function() {
            createTaskLightbox.submit();

            await utils.lightbox.close(createTaskLightbox.el);

            let tasks = taskboardHelper.getBoxTasks(0, 0);

            let tasksSubject = await $$('.e2e-title').getText();

            let findSubject = tasksSubject.indexOf(formFields.subject) !== 1;

            expect(findSubject).to.be.true;
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

    describe('move tasks', function() {
        it('move task between statuses', async function() {
            let initOriginTaskCount = await taskboardHelper.getBoxTasks(0, 0).count();
            let initDestinationTaskCount = await taskboardHelper.getBoxTasks(0, 1).count();

            let taskOrigin = taskboardHelper.getBoxTasks(0, 0).first();
            let destination = taskboardHelper.getBox(0, 1);

            await utils.common.drag(taskOrigin, destination, 0, 10);

            await browser.waitForAngular();

            let originTaskCount = await taskboardHelper.getBoxTasks(0, 0).count();
            let destinationTaskCount = await taskboardHelper.getBoxTasks(0, 1).count();

            expect(originTaskCount).to.be.equal(initOriginTaskCount - 1);
            expect(destinationTaskCount).to.be.equal(initDestinationTaskCount + 1);
        });

        it('move task between US\s', async function() {
            let initOriginTaskCount = await taskboardHelper.getBoxTasks(0, 0).count();
            let initDestinationTaskCount = await taskboardHelper.getBoxTasks(1, 0).count();

            let taskOrigin = taskboardHelper.getBoxTasks(0, 0).first();
            let destination = taskboardHelper.getBox(1, 0);

            await utils.common.drag(taskOrigin, destination, 0, 10);

            await browser.waitForAngular();

            let originTaskCount = await taskboardHelper.getBoxTasks(0, 0).count();
            let destinationTaskCount = await taskboardHelper.getBoxTasks(1, 0).count();

            expect(originTaskCount).to.be.equal(initOriginTaskCount - 1);
            expect(destinationTaskCount).to.be.equal(initDestinationTaskCount + 1);
        });
    });

    describe ('inline', function() {
        it('Change task assigned to', async function(){
            await taskboardHelper.watchersLinks().first().click();

            let lightbox = commonHelper.assignToLightbox();

            await lightbox.waitOpen();

            let assgnedToName = await lightbox.getName(0);

            lightbox.selectFirst();

            await lightbox.waitClose();

            let usAssignedTo = await taskboardHelper.getBoxTasks(0, 0).get(0).$('.card-owner-name').getText();

            expect(assgnedToName).to.be.equal(usAssignedTo);
        });
    });

    describe('Graph', function(){
        let graph = $('.graphics-container');

        it('open', async function() {
            taskboardHelper.toggleGraph();

            await utils.common.waitTransitionTime(graph);

            utils.common.takeScreenshot('taskboard', 'grap-open');

            let open = await utils.common.hasClass(graph, 'open');

            expect(open).to.be.true;
        });

        it('close', async function() {
            taskboardHelper.toggleGraph();

            await utils.common.waitTransitionTime(graph);

            let open = await utils.common.hasClass(graph, 'open');

            expect(open).to.be.false;
        });
    });

    describe('taskboard filters', sharedFilters.bind(this, 'taskboard', () => {
        return taskboardHelper.getTasks().count();
    }));
});
