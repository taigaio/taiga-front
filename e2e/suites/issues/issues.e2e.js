var utils = require('../../utils');
var issuesHelper = require('../../helpers').issues;
var commonHelper = require('../../helpers').common;
var sharedFilters = require('../../shared/filters');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('issues list', function() {
    before(async function() {
        browser.get(browser.params.glob.host + 'project/project-3/issues');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('issues', 'issues');
    });

    describe('create Issue', function() {
        let createIssueLightbox = null;

        before(async function() {
            createIssueLightbox = issuesHelper.getCreateIssueLightbox();

            issuesHelper.openNewIssueLb();

            await createIssueLightbox.waitOpen();
        });

        it('capture screen', function() {
            utils.common.takeScreenshot('issues', 'create-issue');
        });

        it('fill form', async function() {
            // subject
            createIssueLightbox.subject().sendKeys('subject');

            // tags
            await createIssueLightbox.tags().sendKeys('aaa');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            await createIssueLightbox.tags().sendKeys('bbb');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();
        });

        it('upload attachments', commonHelper.lightboxAttachment);

        it('screenshots', function() {
            utils.common.takeScreenshot('issues', 'create-issue-filled');
        });

        it('send form', async function() {
            createIssueLightbox.submit();

            let openNotification = await utils.notifications.success.open();

            expect(openNotification).to.be.true;

            await utils.notifications.success.close();
        });
    });

    describe('bulk create Issue', function() {
        let createIssueLightbox = null;

        before(async function() {
            issuesHelper.openBulk();

            createIssueLightbox = issuesHelper.getBulkCreateLightbox();

            createIssueLightbox.waitOpen();
        });

        it('fill form', function() {
            createIssueLightbox.textarea().sendKeys('aaa');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createIssueLightbox.textarea().sendKeys('bbb');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();
        });

        it('send form', async function() {
            createIssueLightbox.submit();

            await createIssueLightbox.waitClose();

            let notificationSuccess = await utils.notifications.success.open();

            expect(notificationSuccess).to.be.be.true;

            await utils.notifications.success.close();
        });
    });

    it('change order', async function() {
        let table = issuesHelper.getTable();

        // test every column order
        for(let i = 0; i < 7; i++) {
            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.clickColumn(i);
            await htmlChanges();

            htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.clickColumn(i);
            await htmlChanges();
        }
    });

    it('assignto to', async function() {
        let assignToLightbox = commonHelper.assignToLightbox();

        issuesHelper.openAssignTo(0);

        await assignToLightbox.waitOpen();

        let newUserName = await assignToLightbox.getName(2);

        assignToLightbox.select(2);

        await assignToLightbox.waitClose();

        let issueUserName = await issuesHelper.getAssignTo(0);

        expect(issueUserName).to.be.equal(newUserName);
    });

    describe('issues filters', sharedFilters.bind(this, 'issues', () => {
        return issuesHelper.getIssues().count();
    }));
});
