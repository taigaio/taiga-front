var utils = require('../../utils');
var createProjectHelper = require('../../helpers/create-project-helper');
var newProjectScreen = createProjectHelper.newProjectScreen();

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('create-duplicate-delete project', function() {

    it('duplicate project', async function() {
        browser.get(browser.params.glob.host + 'project/new');
        await utils.common.waitLoader();
        utils.common.takeScreenshot('new-project', 'new-project');
        await newProjectScreen.selectDuplicateOption();
        utils.common.takeScreenshot('new-project', 'duplicate-project');
        await newProjectScreen.selectProjectToDuplicate();
        let projectName = 'duplicated-project-' + Date.now();
        newProjectScreen.fillNameAndDescription(projectName, 'Lorem Ipsum')
        await newProjectScreen.createProject();
        let url = await browser.getCurrentUrl();
        expect(url).to.be.equal(browser.params.glob.host + 'project/admin-' + projectName + '/');
    });

    it('create scrum project', async function() {
        browser.get(browser.params.glob.host + 'project/new');
        await utils.common.waitLoader();
        await newProjectScreen.selectScrumOption();
        utils.common.takeScreenshot('new-project', 'create-scrum-project');
        let projectName = 'scrum-project-' + Date.now();
        await newProjectScreen.fillNameAndDescription(projectName, 'Lorem Ipsum');
        await newProjectScreen.createProject();
        let url = await browser.getCurrentUrl();
        expect(url).to.be.equal(browser.params.glob.host + 'project/admin-' + projectName + '/backlog');
    });

    it('create kanban project', async function() {
        browser.get(browser.params.glob.host + 'project/new');
        await utils.common.waitLoader();
        await newProjectScreen.selectKanbanOption();
        utils.common.takeScreenshot('new-project', 'create-kanban-project');
        let projectName = 'kanban-project-' + Date.now();
        await newProjectScreen.fillNameAndDescription(projectName, 'Lorem Ipsum');
        await newProjectScreen.createProject();
        let url = await browser.getCurrentUrl();
        expect(url).to.be.equal(browser.params.glob.host + 'project/admin-' + projectName + '/kanban');
    });

    it('delete', async function() {
        let linkAdmin = $('#nav-admin a');
        utils.common.link(linkAdmin);
        browser.wait(function() {
            return $('.project-details').isPresent();
        });
        await createProjectHelper.delete();
        await browser.waitForAngular();
        let url = await browser.getCurrentUrl();
        expect(url).to.be.equal(browser.params.glob.host);
    });

});
