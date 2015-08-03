var utils = require('../../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('project detail', function() {
    before(async function(){
        browser.get('http://localhost:9001/project/project-0/admin/project-profile/details');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('admin', 'project-detail');
    });

    it('edit tag, description and project settings', async function() {
        let tag = $('.tag-input');

        tag.sendKeys('aaa');
        browser.actions().sendKeys(protractor.Key.ENTER).perform();

        tag.sendKeys('bbb');
        browser.actions().sendKeys(protractor.Key.ENTER).perform();

        let description = $('#project-description');

        description.sendKeys('test test');

        let privateProjectButton = $$('.trans-button').get(1);

        browser.actions()
            .mouseMove(privateProjectButton)
            .click()
            .perform();

        utils.common.takeScreenshot('admin', 'project-detail-filled');

        $('button[type="submit"]').click();

        expect(utils.notifications.success.open()).to.be.eventually.equal(true);
    });
});
