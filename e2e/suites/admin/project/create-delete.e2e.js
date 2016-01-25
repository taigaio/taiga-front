var utils = require('../../../utils');
var createProject = require('../../../helpers').createProject;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('create-delete project', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'projects/');

        await utils.common.waitLoader();
    });

    let lb;

    before(async function() {
        lb = createProject.createProjectLightbox();

        createProject.openWizard();

        await lb.waitOpen();
    });

    it('create - step 1', async function() {
        utils.common.takeScreenshot('project-wizard', 'step1');

        await lb.next();
    });

    it('create - step 2 errors', async function() {
        utils.common.takeScreenshot('project-wizard', 'step2');

        await lb.submit();

        utils.common.takeScreenshot('project-wizard', 'step2-error');

        let errors = await lb.errors().count();

        expect(errors).to.be.equal(2);
    });

    it('create - step 2', async function() {
        lb.name().sendKeys('aaa');
        lb.description().sendKeys('bbb');

        await lb.submit();

        expect(utils.notifications.success.open()).to.be.eventually.true;
    });

    it('delete', async function() {
        let linkAdmin = $('#nav-admin a');
        utils.common.link(linkAdmin);

        browser.wait(function() {
            return $('.project-details').isPresent();
        });

        await createProject.delete();
        await browser.waitForAngular();

        let url = await browser.getCurrentUrl();

        expect(url).to.be.equal(browser.params.glob.host);
    });
});
