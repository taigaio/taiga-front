var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Issue detail', async function(){
    let issuesUrl = "";
    before(async function(){
        await utils.common.goHome();
        await utils.common.goToFirstProject();

        await utils.common.goToIssues();

        issuesUrl = await browser.getCurrentUrl();

        await utils.common.goToFirstIssue();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('assigned to edition', utils.detail.assignedToTesting);

    it('watchers edition', utils.detail.watchersTesting);

    it('history', utils.detail.historyTesting);

    it('block', utils.detail.blockTesting);

    it('attachments', utils.detail.attachmentTesting);

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail updated");
    });

    it('delete', utils.detail.deleteTesting);

    it('redirected', async function (){
        let url = await browser.getCurrentUrl();
        expect(url.endsWith(issuesUrl)).to.be.true;
    });
});
