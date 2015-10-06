var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Issue detail', async function(){
    let issueUrl = '';

    before(async function(){
        utils.nav
            .init()
            .project(1)
            .issues()
            .issue(0)
            .go();

        issueUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('status edition', utils.detail.statusTesting);

    it('assigned to edition', utils.detail.assignedToTesting);

    it('watchers edition', utils.detail.watchersTesting);

    it('history', utils.detail.historyTesting);

    it('block', utils.detail.blockTesting);

    it('attachments', utils.detail.attachmentTesting);

    describe('custom-fields', utils.detail.customFields.bind(this, 2));

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', utils.detail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(issueUrl);
        });
    });
});
