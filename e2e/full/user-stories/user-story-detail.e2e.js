var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('User story detail', function(){
    let backlogUrl = "";
    before(async function(){
      utils.common.goHome();
      utils.common.goToFirstProject();
      utils.common.goToBacklog();
      backlogUrl = await browser.getCurrentUrl();
      utils.common.goToFirstUserStory();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('assigned to edition', utils.detail.assignedToTesting);

    it('watchers edition', utils.detail.watchersTesting);

    it('history', utils.detail.historyTesting);

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail updated");
    });

    it('block', utils.detail.blockTesting);

    it('attachments', utils.detail.attachmentTesting)

    it('delete', utils.detail.deleteTesting);

    it('redirected', async function (){
        let url = await browser.getCurrentUrl();
        expect(url.endsWith(backlogUrl+"?no-milestone=1")).to.be.true;
    });
})
