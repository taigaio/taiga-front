var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('change password', function() {
    before(async function(){
        browser.get('http://localhost:9001/user-settings/user-change-password');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('edit-user-profile', 'change-password');
    });

    it('retype different', async function() {
        await $('#current-password').sendKeys('123123');
        await $('#new-password').sendKeys('123456');
        await $('#retype-password').sendKeys('000');

        $('button[type="submit"]').click();

        expect(utils.notifications.error.open()).to.be.eventually.equal(true);
    });

    it('incorrect current password', async function() {
        await $('#current-password').sendKeys('aaaa');
        await $('#new-password').sendKeys('123456');
        await $('#retype-password').sendKeys('123456');

        $('button[type="submit"]').click();

        expect(utils.notifications.error.open()).to.be.eventually.equal(true);
    });

    it('change password', async function() {
        await $('#current-password').sendKeys('123123');
        await $('#new-password').sendKeys('aaabbb');
        await $('#retype-password').sendKeys('aaabbb');

        $('button[type="submit"]').click();

        expect(utils.notifications.success.open()).to.be.eventually.equal(true);

        //restore
        await $('#current-password').sendKeys('aaabbb');
        await $('#new-password').sendKeys('123123');
        await $('#retype-password').sendKeys('123123');

        $('button[type="submit"]').click();
    });
});
