var utils = require('../utils');
var kanbanHelper = require('../helpers').kanban;
var backlogHelper = require('../helpers').backlog;
var commonHelper = require('../helpers').common;

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
            createUSLightbox.setRole(1, 3);
            createUSLightbox.setRole(2, 3);
            createUSLightbox.setRole(3, 3);
            createUSLightbox.setRole(4, 3);

            let totalPoints = await createUSLightbox.getRolePoints();

            expect(totalPoints).to.be.equal('4');

            // tags
            createUSLightbox.tags().sendKeys('www');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createUSLightbox.tags().sendKeys('xxx');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            // description
            createUSLightbox.description().sendKeys(formFields.description);

            //settings
            createUSLightbox.settings(1).click();
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
            createUSLightbox.setRole(1, 3);
            createUSLightbox.setRole(2, 3);
            createUSLightbox.setRole(3, 3);
            createUSLightbox.setRole(4, 3);

            let totalPoints = await createUSLightbox.getRolePoints();

            expect(totalPoints).to.be.equal('4');

            // tags
            createUSLightbox.tags().sendKeys('www');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createUSLightbox.tags().sendKeys('xxx');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            // description
            createUSLightbox.description().sendKeys(formFields.description);

            //settings
            createUSLightbox.settings(1).click();
        });

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

        it('fold cars', async function() {
            kanbanHelper.foldCards(0);

            utils.common.takeScreenshot('kanban', 'fold-cards');

            let minimized = await $$('.kanban-task-minimized').count();

            expect(minimized).to.be.above(1);
        });

        it('unfold cars', async function() {
            kanbanHelper.unFoldCards(0);

            let minimized = await $$('.kanban-task-minimized').count();

            expect(minimized).to.be.equal(0);
        });
    });

    it('move us between columns', async function() {
        let initOriginUsCount = await kanbanHelper.getBoxUss(0).count();
        let initDestinationUsCount = await kanbanHelper.getBoxUss(1).count();

        let usOrigin = kanbanHelper.getBoxUss(0).first();
        let destination = kanbanHelper.getColumns().get(1);

        await utils.common.drag(usOrigin, destination);

        browser.waitForAngular();

        let originUsCount = await kanbanHelper.getBoxUss(0).count();
        let destinationUsCount = await kanbanHelper.getBoxUss(1).count();

        expect(originUsCount).to.be.equal(initOriginUsCount - 1);
        expect(destinationUsCount).to.be.equal(initDestinationUsCount + 1);
    });

    describe('archive', function() {
        utils.common.browserSkip('firefox', 'move to archive', async function() {
            let initOriginUsCount = await kanbanHelper.getBoxUss(3).count();

            let usOrigin = kanbanHelper.getBoxUss(3).first();
            let destination = kanbanHelper.getColumns().last();

            await kanbanHelper.scrollRight();

            await utils.common.drag(usOrigin, destination);

            browser.waitForAngular();

            let originUsCount = await kanbanHelper.getBoxUss(3).count();

            utils.common.takeScreenshot('kanban', 'archive');

            expect(originUsCount).to.be.equal(initOriginUsCount - 1);
        });

        utils.common.browserSkip('firefox', 'show archive', async function() {
            $('.icon-open-eye').click();

            await kanbanHelper.scrollRight();

            utils.common.takeScreenshot('kanban', 'archive-open');

            let usCount = await kanbanHelper.getBoxUss(5).count();

            expect(usCount).to.be.above(0);
        });

        utils.common.browserSkip('firefox', 'close archive', async function() {
            $('.icon-closed-eye').click();

            let usCount = await kanbanHelper.getBoxUss(5).count();

            expect(usCount).to.be.equal(0);
        });
    });

    it('edit assigned to', async function() {
        await kanbanHelper.watchersLinks().first().click();

        let lightbox = commonHelper.assignToLightbox();

        await lightbox.waitOpen();

        let assgnedToName = await lightbox.getName(0);

        lightbox.selectFirst();

        await lightbox.waitClose();

        let usAssignedTo = await kanbanHelper.getBoxUss(0).get(0).$('.task-assigned').getText();

        expect(assgnedToName).to.be.equal(usAssignedTo);
    });
});
