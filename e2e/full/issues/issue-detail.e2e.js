var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Issue detail', function(){
    before(async function(){
        browser.get('http://localhost:9001/project/project-2/issue/95');
        await utils.common.waitLoader();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail");
    });

    it('assigned to', utils.detailAssignedTo.assignedToTesting);

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail updated");
    });
})
