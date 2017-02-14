var utils = require('../utils');
var createProject = require('../helpers').createProject;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('create-duplicate-delete project', function() {
    before(async function() {
        browser.get(browser.params.glob.host + 'project/new');
        await utils.common.waitLoader();

        utils.common.takeScreenshot('project-create', 'create-project');
    });

    it.only('duplicate project', async function() {
        let dup = await $('.e2e-duplicate-project');
        let createProjectUrl = await browser.getCurrentUrl();
        let projectName = 'taigatest';

        await createProject.openDuplicateWizard();

        await createProject.selectProjectToDuplicate();
        await $('.e2e-duplicate-project-title').sendKeys(projectName);
        await $('.e2e-duplicate-project-description').sendKeys('Lorem Ipsum');

        await createProject.duplicateProject();

        let projectUrl = await browser.getCurrentUrl();
        expect(projectUrl).not.to.be.equal(originalUrl);
        expect(projectUrl)to.be.equal('project/' + projectName);

    })

    // it('create project error', async function() {
    //     utils.common.takeScreenshot('project-wizard', 'create-project-errors');
    //
    //     await  lb.submit();
//
//         let errors = await lb.errors().count();
//
//         expect(errors).to.be.equal(2);
//     });
//
//     it('create project', async function() {
//         let originalUrl = await browser.getCurrentUrl();
//
//         lb.name().sendKeys('aaa');
//         lb.description().sendKeys('bbb');
//
//         await lb.submit();
//
//         let projectUrl = await browser.getCurrentUrl();
//
//         expect(projectUrl).not.to.be.equal(originalUrl);
//     });
//
//     it('delete', async function() {
//         let linkAdmin = $('#nav-admin a');
//         utils.common.link(linkAdmin);
//
//         browser.wait(function() {
//             return $('.project-details').isPresent();
//         });
//
//         await createProject.delete();
//         await browser.waitForAngular();
//
//         let url = await browser.getCurrentUrl();
//
//         expect(url).to.be.equal(browser.params.glob.host);
//     });
});
