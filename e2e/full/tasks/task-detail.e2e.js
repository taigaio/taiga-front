var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Task detail', function(){
    let sprintUrl = "";
    before(async function(){
        utils.common.goHome();
        utils.common.goToFirstProject();
        utils.common.goToBacklog();
        utils.common.goToFirstSprint();
        sprintUrl = await browser.getCurrentUrl();
        utils.common.goToFirstTask();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('assigned to edition', utils.detail.assignedToTesting);

    it('history', utils.detail.historyTesting);
    
    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail updated");
    });

    it('delete', utils.detail.deleteTesting);

    it('redirected', async function (){
        let url = await browser.getCurrentUrl();
        expect(url.endsWith(sprintUrl)).to.be.true;
    });
})
