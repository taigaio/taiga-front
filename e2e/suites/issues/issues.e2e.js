var utils = require('../../utils');
var issuesHelper = require('../../helpers').issues;
var commonHelper = require('../../helpers').common;

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

            expect(utils.notifications.success.open()).to.be.eventually.true;

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

    describe('filters', function() {
        it('by ref', async function() {
            let table = issuesHelper.getTable();
            let issues = issuesHelper.getIssues();
            let issue = issues.get(0);
            issue = await issuesHelper.parseIssue(issue);
            let filterInput = issuesHelper.getFilterInput();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            await filterInput.sendKeys(issue.ref);
            await htmlChanges();

            let newIssuesCount = await issues.count();

            expect(newIssuesCount).to.be.equal(1);

            htmlChanges = await utils.common.outerHtmlChanges(table);
            await utils.common.clear(filterInput);
            await htmlChanges();
        });

        it('by subject', async function() {
            let table = issuesHelper.getTable();
            let issues = issuesHelper.getIssues();
            let issue = issues.get(0);
            issue = await issuesHelper.parseIssue(issue);
            let filterInput = issuesHelper.getFilterInput();

            let oldIssuesCount = await $$('.row.table-main').count();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            await filterInput.sendKeys(issue.subject);
            await htmlChanges();

            let newIssuesCount = await issues.count();

            expect(newIssuesCount).not.to.be.equal(oldIssuesCount);
            expect(newIssuesCount).to.be.above(0);

            htmlChanges = await utils.common.outerHtmlChanges(table);
            await utils.common.clear(filterInput);
            await htmlChanges();
        });

        it('by type', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(0).$('a').click();
            issuesHelper.selectFilter(0);

            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('by status', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(1).$('a').click();
            issuesHelper.selectFilter(0);
            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('by severity', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(2).$('a').click();
            issuesHelper.selectFilter(0);
            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('by priorities', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(3).$('a').click();
            issuesHelper.selectFilter(0);
            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('by tags', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(4).$('a').click();
            issuesHelper.selectFilter(1);
            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('by assigned to', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(5).$('a').click();
            issuesHelper.selectFilter(0);
            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('by created by', async function() {
            let table = issuesHelper.getTable();

            let htmlChanges = await utils.common.outerHtmlChanges(table);
            issuesHelper.filtersCats().get(6).$('a').click();
            issuesHelper.selectFilter(0);
            await htmlChanges();

            issuesHelper.backToFilters();

            await issuesHelper.removeFilters();
        });

        it('empty', async function() {
            let table = issuesHelper.getTable();
            let htmlChanges = await utils.common.outerHtmlChanges(table);

            let filterInput = issuesHelper.getFilterInput();

            await filterInput.sendKeys(new Date().getTime());

            await htmlChanges();

            let newIssuesCount = await issuesHelper.getIssues().count();

            expect(newIssuesCount).to.be.equal(0);

            await utils.common.takeScreenshot('issues', 'empty-issues');
            await utils.common.clear(filterInput);
        });

        it('save custom filter', async function() {
            issuesHelper.filtersCats().get(1).$('a').click();
            issuesHelper.selectFilter(0);

            await browser.waitForAngular();

            await issuesHelper.saveFilter('custom');

            let customFilters = await issuesHelper.getCustomFilters().count();

            expect(customFilters).to.be.equal(1);

            await issuesHelper.removeFilters();
            issuesHelper.backToFilters();
        });

        it('apply custom filter', async function() {
            let table = issuesHelper.getTable();
            let htmlChanges = await utils.common.outerHtmlChanges(table);

            issuesHelper.filtersCats().get(7).$('a').click();

            issuesHelper.selectFilter(0);

            await htmlChanges();

            await issuesHelper.removeFilters();
        });

        it('remove custom filter', async function() {
            await issuesHelper.removeCustomFilters();

            let customFilterCount = await issuesHelper.getCustomFilters().count();

            expect(customFilterCount).to.be.equal(0);
        });
    });
});
