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

        utils.common.takeScreenshot('project-wizard', 'create-project');
    });

    it('create project error', async function() {
        utils.common.takeScreenshot('project-wizard', 'create-project-errors');

        await lb.submit();

        let errors = await lb.errors().count();

        expect(errors).to.be.equal(2);
    });

    it('create project', async function() {
        lb.name().sendKeys('aaa');
        lb.description().sendKeys('bbb');

        await lb.submit();

        let open = utils.notifications.success.open();

        expect(open).to.be.equal.true;

        await utils.notifications.success.close();
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
