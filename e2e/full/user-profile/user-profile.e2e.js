var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('user profile', function() {
    describe('current user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + 'profile');

            await utils.common.waitLoader();

            utils.common.takeScreenshot('user-profile', 'current-user-activity');
        });

        it('activity tab pagination', async function() {
            let startTotal = await $$('div[tg-user-timeline-item]').count();

            await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
            await browser.waitForAngular();

            let endTotal = await $$('div[tg-user-timeline-item]').count();

            let hasMoreItems = startTotal < endTotal;

            expect(hasMoreItems).to.be.equal(true);
        });

        it('conctacts tab', async function() {
            $$('.tab').get(1).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'current-user-contacts');

            let contactsCount = await $$('.profile-contact-single').count();

            expect(contactsCount).to.be.above(0);
        });

        utils.common.browserSkip('internet explorer', 'edit profile hover', async function() {
            let userImage = $('.profile-image-wrapper');

            await browser.actions().mouseMove(userImage).perform();

            let profileEdition = userImage.$('.profile-edition');

            await utils.common.waitTransitionTime(profileEdition);

            utils.common.takeScreenshot('user-profile', 'image-hover');

            expect(profileEdition.isDisplayed()).to.be.eventually.true;
        });
    });

    describe('other user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + 'profile/user7');

            await utils.common.waitLoader();

            utils.common.takeScreenshot('user-profile', 'other-user-activity');
        });

        it('activity tab pagination', async function() {
            let startTotal = await $$('div[tg-user-timeline-item]').count();

            await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
            await browser.waitForAngular();

            let endTotal = await $$('div[tg-user-timeline-item]').count();

            let hasMoreItems = startTotal < endTotal;

            expect(hasMoreItems).to.be.equal(true);
        });

        it('projects tab', async function() {
            $$('.tab').get(1).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-projects');

            let projectsCount = await $$('.project-list-single').count();

            expect(projectsCount).to.be.above(0);
        });

        it('conctacts tab', async function() {
            $$('.tab').get(2).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-contacts');

            let contactsCount = await $$('.profile-contact-single').count();

            expect(contactsCount).to.be.above(0);
        });
    });
});
