var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('user profilei - projects', function() {
    describe('other user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile/user7');

            await utils.common.waitLoader();

            $$('.tab').get(1).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-projects');
        });

        it('projects tab', async function() {
            let projectsCount = await $$('.project-list-single').count();

            expect(projectsCount).to.be.above(0);
        });
    });
});
