/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');
var kanbanHelper = require('../helpers').kanban;
var backlogHelper = require('../helpers').backlog;
var commonHelper = require('../helpers').common;
var filterHelper = require('../helpers/filters-helper');
var sharedFilters = require('../shared/filters');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('kanban', function() {
    before(async function() {
        browser.get(browser.params.glob.host + 'project/project-0/kanban');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('kanban', 'kanban');
    });

    it('zoom', async function() {
        kanbanHelper.zoom(1);
        await browser.sleep(1000);
        utils.common.takeScreenshot('kanban', 'zoom1');

        kanbanHelper.zoom(2);
        await browser.sleep(1000);
        utils.common.takeScreenshot('kanban', 'zoom2');

        kanbanHelper.zoom(3);
        await browser.sleep(1000);
        utils.common.takeScreenshot('kanban', 'zoom3');

        kanbanHelper.zoom(4);
        await browser.sleep(1000);
        utils.common.takeScreenshot('kanban', 'zoom4');
    });

    describe('create us', function() {
        let createUSLightbox = null;
        let formFields = {};

        before(async function() {
            kanbanHelper.openNewUsLb(0);

            createUSLightbox = backlogHelper.getCreateEditUsLightbox();

            await createUSLightbox.waitOpen();
        });

        it('capture screen', function() {
            utils.common.takeScreenshot('kanban', 'create-us');
        });

        it('fill form', async function() {
            let date = Date.now();

            formFields.subject = 'test subject' + date;
            formFields.description = 'test description' + date;

            // subject
            createUSLightbox.subject().sendKeys(formFields.subject);

            // roles
            await createUSLightbox.setRole(0, 3);
            await createUSLightbox.setRole(1, 3);
            await createUSLightbox.setRole(2, 3);
            await createUSLightbox.setRole(3, 3);

            let totalPoints = await createUSLightbox.getRolePoints();

            expect(totalPoints).to.be.equal('4');

            // tags
            commonHelper.tags();

            // description
            createUSLightbox.description().sendKeys(formFields.description);

            //settings
            createUSLightbox.settings(1).click();
        });

        it('upload attachments', commonHelper.lightboxAttachment);

        it('screenshots', function() {
            utils.common.takeScreenshot('kanban', 'create-us-filled');
        });

        it('send form', async function() {
            createUSLightbox.submit();

            await utils.lightbox.close(createUSLightbox.el);

            let ussTitles = await kanbanHelper.getColumnUssTitles(0);

            let findSubject = ussTitles.indexOf(formFields.subject) !== 1;

            expect(findSubject).to.be.true;
        });
    });


    describe('edit us', function() {
        let createUSLightbox = null;
        let formFields = {};

        before(async function() {
            kanbanHelper.editUs(0, 0);

            createUSLightbox = backlogHelper.getCreateEditUsLightbox();

            await createUSLightbox.waitOpen();
        });

        it('capture screen', function() {
            utils.common.takeScreenshot('kanban', 'edit-us');
        });

        it('fill form', async function() {
            let date = Date.now();

            formFields.subject = 'test subject' + date;
            formFields.description = 'test description' + date;

            // subject
            let subject = createUSLightbox.subject();

            await subject.clear();

            subject.sendKeys(formFields.subject);

            // roles
            await createUSLightbox.setRole(0, 3);
            await createUSLightbox.setRole(1, 3);
            await createUSLightbox.setRole(2, 3);
            await createUSLightbox.setRole(3, 3);

            let totalPoints = await createUSLightbox.getRolePoints();

            expect(totalPoints).to.be.equal('4');

            // tags
            createUSLightbox.tags();

            // description
            createUSLightbox.description().sendKeys(formFields.description);

            //settings
            createUSLightbox.settings(1).click();
        });

        it('upload attachments', commonHelper.lightboxAttachment);

        it('send form', async function() {
            createUSLightbox.submit();

            await utils.lightbox.close(createUSLightbox.el);

            let ussTitles = await kanbanHelper.getColumnUssTitles(0);
            let findSubject = ussTitles.indexOf(formFields.subject) !== -1;

            expect(findSubject).to.be.true;
        });
    });

    describe('bulk create', function() {
        let createUSLightbox;

        before(async function() {
            kanbanHelper.openBulkUsLb(0);

            createUSLightbox = backlogHelper.getBulkCreateLightbox();

            await createUSLightbox.waitOpen();
        });

        it('fill form', function() {
            createUSLightbox.textarea().sendKeys('aaa');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createUSLightbox.textarea().sendKeys('bbb');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();
        });

        it('send form', async function() {
            let ussCount = await kanbanHelper.getBoxUss(0).count();

            createUSLightbox.submit();

            await utils.lightbox.close(createUSLightbox.el);

            let newUssCount = await kanbanHelper.getBoxUss(0).count();

            expect(newUssCount).to.be.equal(ussCount + 2);
        });
    });

    describe('folds', function() {
        it('fold column', async function() {
            kanbanHelper.foldColumn(0);

            utils.common.takeScreenshot('kanban', 'fold-column');

            let foldedColumns = await $$('.vfold.task-column').count();

            expect(foldedColumns).to.be.equal(1);
        });

        it('unfold column', async function() {
            kanbanHelper.unFoldColumn(0);

            let foldedColumns = await $$('.vfold.task-column').count();

            expect(foldedColumns).to.be.equal(0);
        });
    });

    it('move us between columns', async function() {
        let initOriginUsCount = await kanbanHelper.getBoxUss(0).count();
        let initDestinationUsCount = await kanbanHelper.getBoxUss(1).count();

        let usOrigin = kanbanHelper.getBoxUss(0).first();
        let destination = kanbanHelper.getColumns().get(1);

        await utils.common.drag(usOrigin, destination, 0, 10);

        browser.waitForAngular();

        let originUsCount = await kanbanHelper.getBoxUss(0).count();
        let destinationUsCount = await kanbanHelper.getBoxUss(1).count();

        expect(originUsCount).to.be.equal(initOriginUsCount - 1);
        expect(destinationUsCount).to.be.equal(initDestinationUsCount + 1);
    });

    describe('archive', function() {
        it('move to archive', async function() {
            let initOriginUsCount = await kanbanHelper.getBoxUss(3).count();

            let usOrigin = kanbanHelper.getBoxUss(3).first();
            let destination = kanbanHelper.getColumns().last();

            await kanbanHelper.scrollRight();

            await utils.common.drag(usOrigin, destination, 0, 10);

            browser.waitForAngular();

            let originUsCount = await kanbanHelper.getBoxUss(3).count();

            utils.common.takeScreenshot('kanban', 'archive');

            expect(originUsCount).to.be.equal(initOriginUsCount - 1);
        });
    });

    it('edit assigned to', async function() {
        await kanbanHelper.watchersLinks().first().click();

        let lightbox = commonHelper.assignToLightbox();

        await lightbox.waitOpen();

        let assgnedToName = await lightbox.getName(0);

        lightbox.selectFirst();

        await lightbox.waitClose();

        let usAssignedTo = await kanbanHelper.getBoxUss(0).get(0).$('.card-owner-name').getText();

        expect(assgnedToName).to.be.equal(usAssignedTo);
    });

    describe('kanban filters', sharedFilters.bind(this, 'kanban', () => {
        return kanbanHelper.getUss().count();
    }));
});
