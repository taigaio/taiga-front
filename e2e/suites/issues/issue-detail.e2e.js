var utils = require('../../utils');
var sharedDetail = require('../../shared/detail');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Issue detail', async function(){
    let issueUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .issues()
            .issue(0)
            .go();

        issueUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail");
    });

    it('title edition', sharedDetail.titleTesting);

    it('tags edition', sharedDetail.tagsTesting);

    it('description edition', sharedDetail.descriptionTesting);

    it('status edition', sharedDetail.statusTesting);

    describe('assigned to edition', sharedDetail.assignedToTesting);

    describe('watchers edition', sharedDetail.watchersTesting);

    it('history', sharedDetail.historyTesting);

    it('block', sharedDetail.blockTesting);

    it('attachments', sharedDetail.attachmentTesting);

    describe('custom-fields', sharedDetail.customFields.bind(this, 2));

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', sharedDetail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(issueUrl);
        });
    });
});
