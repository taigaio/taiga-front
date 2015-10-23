var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('user profile - contacts', function() {
    describe('current user', function() {
        before(async function(){
            browser.get('http://localhost:9001/profile');

            await utils.common.waitLoader();

            $$('.tab').get(4).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'current-user-contacts');
        });

        it('conctacts tab', async function() {
            let contactsCount = await $$('.profile-contact-single').count();

            expect(contactsCount).to.be.above(0);
        });
    });

    describe('other user', function() {
        before(async function(){
            browser.get('http://localhost:9001/profile/user7');

            await utils.common.waitLoader();

            $$('.tab').get(5).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-contacts');
        });

        it('conctacts tab', async function() {
            let contactsCount = await $$('.profile-contact-single').count();

            expect(contactsCount).to.be.above(0);
        });
    });
});
