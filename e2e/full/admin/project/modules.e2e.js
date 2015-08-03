var utils = require('../../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('modules', function() {
    before(async function(){
        browser.get('http://localhost:9001/project/project-0/admin/project-profile/modules');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('admin', 'project-modules');
    });

    it('disable module', async function() {
        let functionalities = $$('.functionality');

        let functionality = functionalities.get(0);

        let label = functionality.$('label');

        browser.actions()
            .mouseMove(label)
            .click()
            .perform();

        $('button[type="submit"]').click();

        let active = await utils.common.hasClass(functionality, 'active');

        expect(utils.notifications.success.open()).to.be.eventually.equal(true);
        expect(active).to.be.false;
    });

    it('enable module', async function() {
        let functionalities = $$('.functionality');

        let functionality = functionalities.get(0);

        let label = functionality.$('label');

        browser.actions()
            .mouseMove(label)
            .click()
            .perform();

        $('button[type="submit"]').click();

        let active = await utils.common.hasClass(functionality, 'active');

        expect(utils.notifications.success.open()).to.be.eventually.equal(true);
        expect(active).to.be.true;
    });

    it('enable videoconference', async function() {
        let functionality = $$('.functionality').get(4);

        let label = functionality.$('label');

        browser.actions()
            .mouseMove(label)
            .click()
            .perform();

        let videoconference = functionality.$$('select').get(0);

        videoconference.$(`option:nth-child(1)`).click();

        let salt = functionality.$$('select').get(0);

        salt.sendKeys('abccceee');

        $('button[type="submit"]').click();
        expect(utils.notifications.success.open()).to.be.eventually.equal(true);
    });
});
