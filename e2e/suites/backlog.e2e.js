/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');
var backlogHelper = require('../helpers').backlog;
var commonHelper = require('../helpers').common;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

var sharedFilters = require('../shared/filters');

chai.use(chaiAsPromised);
var expect = chai.expect;


describe('backlog', function() {
    before(async function() {
        browser.get(browser.params.glob.host + 'project/project-3/backlog');
        await utils.common.waitLoader();

        utils.common.takeScreenshot('backlog', 'backlog');
    });

    describe('create US', function() {
        let createUSLightbox = null;

        before(async function() {
            backlogHelper.openNewUs();

            createUSLightbox = backlogHelper.getCreateEditUsLightbox();

            await createUSLightbox.waitOpen();
        });

        it('capture screen', function() {
            utils.common.takeScreenshot('backlog', 'create-us');
        });

        it('fill form', async function() {
            // subject
            createUSLightbox.subject().sendKeys('subject');

            // roles
            await createUSLightbox.setRole(1, 3);
            await createUSLightbox.setRole(3, 4);

            let totalPoints = await createUSLightbox.getRolePoints();

            expect(totalPoints).to.be.equal('3');

            // status
            createUSLightbox.status(2).click();

            // tags
            commonHelper.tags();

            // description
            createUSLightbox.description().sendKeys('test test');

            //settings
            createUSLightbox.settings(0).click();

            await utils.common.waitTransitionTime(createUSLightbox.settings(0));
        });

        it('upload attachments', commonHelper.lightboxAttachment);

        it('screenshots', function() {
            utils.common.takeScreenshot('backlog', 'create-us-filled');
        });

        it('send form', async function() {
            let htmlChanges = await utils.common.outerHtmlChanges('.backlog-table-body');
            let usCount = await backlogHelper.userStories().count();

            createUSLightbox.submit();

            await utils.lightbox.close(createUSLightbox.el);
            await htmlChanges();

            let newUsCount = await backlogHelper.userStories().count();

            expect(newUsCount).to.be.equal(usCount + 1);
        });
    });

    describe('bulk create US', function() {
        let createUSLightbox = null;

        before(async function() {
            backlogHelper.openBulk();

            createUSLightbox = backlogHelper.getBulkCreateLightbox();

            await createUSLightbox.waitOpen();
        });

        it('fill form', function() {
            createUSLightbox.textarea().sendKeys('aaa');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();

            createUSLightbox.textarea().sendKeys('bbb');
            browser.actions().sendKeys(protractor.Key.ENTER).perform();
        });

        it('send form', async function() {
            let usCount = await backlogHelper.userStories().count();

            createUSLightbox.submit();

            await createUSLightbox.waitClose();

            let newUsCount = await backlogHelper.userStories().count();

            expect(newUsCount).to.be.equal(usCount + 2);
        });
    });

    describe('edit US', function() {
        let editUSLightbox = null;

        before(async function() {
            backlogHelper.openUsBacklogEdit(0);

            editUSLightbox = backlogHelper.getCreateEditUsLightbox();

            await editUSLightbox.waitOpen();
        });

        it('fill form', async function() {
            // subject
            editUSLightbox.subject().sendKeys('subjectedit');

            // roles
            await editUSLightbox.setRole(0, 3);
            await editUSLightbox.setRole(1, 3);
            await editUSLightbox.setRole(2, 3);
            await editUSLightbox.setRole(3, 3);

            let totalPoints = await editUSLightbox.getRolePoints();

            expect(totalPoints).to.be.equal('4');

            // status
            editUSLightbox.status(3).click();

            // tags
            editUSLightbox.tags();

            // description
            editUSLightbox.description().sendKeys('test test test test');

            //settings
            editUSLightbox.settings(1).click();
        });

        it('upload attachments', commonHelper.lightboxAttachment);

        it('send form', async function() {
            editUSLightbox.submit();

            await editUSLightbox.waitClose();
        });
    });


    it('edit status inline', async function() {
        await backlogHelper.setUsStatus(0, 1);

        // debounce
        await browser.sleep(2000);

        let statusText = await backlogHelper.setUsStatus(0, 2);

        expect(statusText).to.be.equal('In progress');
    });

    it('edit points inline', async function() {
        let usPointsOriginal = await backlogHelper.getUsPoints(0, 1, 1);

        await backlogHelper.setUsPoints(0, 1, 1);

        let usPointsNew = await backlogHelper.getUsPoints(0);

        expect(usPointsOriginal).not.to.be.equal(usPointsNew);
    });

    it('delete US', async function() {
        let usCount = await backlogHelper.userStories().count();

        backlogHelper.deleteUs(0);

        await utils.lightbox.confirm.ok();

        let newUsCount = await backlogHelper.userStories().count();

        expect(newUsCount).to.be.equal(usCount - 1);
    });

    it('drag backlog us', async function() {
        let dragableElements = backlogHelper.userStories();

        let dragElement = dragableElements.get(4);
        let dragElementHandler = dragElement.$('.icon-drag');
        let draggedElementRef = await backlogHelper.getUsRef(dragElement);


        await utils.common.drag(dragElementHandler, dragableElements.get(0));
        await browser.waitForAngular();

        let firstElementTextRef = await backlogHelper.getUsRef(dragableElements.get(0));

        expect(firstElementTextRef).to.be.equal(draggedElementRef);
    });

    it('reorder multiple us', async function() {
        let dragableElements = backlogHelper.userStories();

        let count = await dragableElements.count();

        let draggedRefs = [];

        //element 1
        let dragElement = dragableElements.get(count - 1);
        dragElement.$('input[type="checkbox"]').click();
        let ref1 = await backlogHelper.getUsRef(dragElement);
        draggedRefs.push(await backlogHelper.getUsRef(dragElement));

        //element 2
        dragElement = dragableElements.get(count - 2);
        dragElement.$('input[type="checkbox"]').click();
        let ref2 = await backlogHelper.getUsRef(dragElement);
        draggedRefs.push(await backlogHelper.getUsRef(dragElement));

        await utils.common.drag(dragElement.$('.icon-drag'), dragableElements.get(0));

        let elementRef1 = await backlogHelper.getUsRef(dragableElements.get(0));
        let elementRef2 = await backlogHelper.getUsRef(dragableElements.get(1));

        expect(elementRef2).to.be.equal(draggedRefs[0]);
        expect(elementRef1).to.be.equal(draggedRefs[1]);
    });

    it('drag multiple us to milestone', async function() {
        let sprint = backlogHelper.sprints().get(0);
        let initUssSprintCount = await backlogHelper.getSprintUsertories(sprint).count();

        let dragableElements = backlogHelper.userStories();

        let draggedRefs = [];

        // the us 1 and 2 are selected on the previous test

        let dragElement = dragableElements.get(0);
        let dragElementHandler = dragElement.$('.icon-drag');

        await utils.common.drag(dragElementHandler, sprint.$('.sprint-table'));
        await browser.waitForAngular();

        let ussSprintCount = await backlogHelper.getSprintUsertories(sprint).count();

        expect(ussSprintCount).to.be.equal(initUssSprintCount + 2);
    });

    it('drag us to milestone', async function() {
        let sprint = backlogHelper.sprints().get(0).$('.sprint-table');

        let dragableElements = backlogHelper.userStories();
        let dragElement = dragableElements.get(0);
        let dragElementHandler = dragElement.$('.icon-drag');

        let draggedElementRef = await backlogHelper.getUsRef(dragElement);

        let initUssSprintCount = await backlogHelper.getSprintUsertories(sprint).count();

        await utils.common.drag(dragElementHandler, sprint);
        await browser.waitForAngular();

        let ussSprintCount = await backlogHelper.getSprintUsertories(sprint).count();

        expect(ussSprintCount).to.be.equal(initUssSprintCount + 1);
    });

    it('move to lastest sprint button', async function() {
        let dragElement = backlogHelper.userStories().first();

        dragElement.$('input[type="checkbox"]').click();

        let draggedRef = await backlogHelper.getUsRef(dragElement);

        let htmlChanges = await utils.common.outerHtmlChanges('.backlog-table-body');

        $('.e2e-move-to-sprint').click();

        await htmlChanges();

        let sprint = backlogHelper.sprintsOpen().last();

        let sprintRefs = await backlogHelper.getSprintsRefs(sprint);

        expect(sprintRefs.indexOf(draggedRef)).to.be.not.equal(-1);
    });

    it('reorder milestone us', async function() {
        let sprint = backlogHelper.sprints().get(0);
        let dragableElements = backlogHelper.getSprintUsertories(sprint);

        let dragElement = await dragableElements.get(3);
        let draggedElementRef = await backlogHelper.getUsRef(dragElement);

        await utils.common.drag(dragElement, dragableElements.get(0));
        await browser.waitForAngular();

        let firstElementRef = await backlogHelper.getUsRef(dragableElements.get(0));

        expect(firstElementRef).to.be.equal(firstElementRef);
    });

    it('drag us from milestone to milestone', async function() {
        let sprint1 = backlogHelper.sprints().get(0);
        let sprint2 = backlogHelper.sprints().get(1);

        let initUssSprintCount = await backlogHelper.getSprintUsertories(sprint2).count();

        let dragElement = backlogHelper.getSprintUsertories(sprint1).get(0);

        await utils.common.drag(dragElement, sprint2.$('.sprint-table'));
        await browser.waitForAngular();

        let firstElement = backlogHelper.getSprintUsertories(sprint2).get(0);

        let ussSprintCount = await backlogHelper.getSprintUsertories(sprint2).count();

        expect(ussSprintCount).to.be.equal(initUssSprintCount + 1);
    });

    utils.common.browserSkip('internet explorer', 'select us with SHIFT', async function() {
        await browser.sleep(5000);
        let dragableElements = backlogHelper.userStories();

        let firstInput = dragableElements.get(0).$('input[type="checkbox"]');
        let lastInput = dragableElements.get(3).$('input[type="checkbox"]');

        await browser.actions()
            .mouseMove(firstInput)
            .keyDown(protractor.Key.SHIFT)
            .click()
            .mouseMove(lastInput)
            .click()
            .keyUp(protractor.Key.SHIFT)
            .perform();

        let count = await backlogHelper.selectedUserStories().count();

        expect(count).to.be.equal(4);
    });

    it('role filters', async function() {
        await backlogHelper.fiterRole(1);

        utils.common.takeScreenshot('backlog', 'backlog-role-filters');

        let usPoints = await backlogHelper.getUsPoints(0);

        expect(usPoints).to.match(/[0-9?]+\s\/\s[0-9?]+/);
    });

    describe('milestones', function() {
        it('create', async function() {
            backlogHelper.openNewMilestone();

            let createMilestoneLightbox = backlogHelper.getCreateEditMilestone();

            await createMilestoneLightbox.waitOpen();

            utils.common.takeScreenshot('backlog', 'create-milestone');

            let sprintName = 'sprintName' + new Date().getTime();

            createMilestoneLightbox.name().sendKeys(sprintName);

            createMilestoneLightbox.submit();
            await browser.waitForAngular();

            // debounce
            await browser.sleep(2000);

            let sprintTitles = await backlogHelper.getSprintsTitles();

            expect(sprintTitles.indexOf(sprintName)).to.be.not.equal(-1);
        });

        it('edit', async function() {
            backlogHelper.openMilestoneEdit(0);

            let createMilestoneLightbox = backlogHelper.getCreateEditMilestone();

            await createMilestoneLightbox.waitOpen();

            await createMilestoneLightbox.name().clear();

            let sprintName = 'sprintName' + new Date().getTime();

            createMilestoneLightbox.name().sendKeys(sprintName);

            createMilestoneLightbox.submit();

            await createMilestoneLightbox.waitClose();

            let sprintTitles = await backlogHelper.getSprintsTitles();

            expect(sprintTitles.indexOf(sprintName)).to.be.not.equal(-1);
        });

        it('delete', async function() {
            backlogHelper.openMilestoneEdit(0);

            let createMilestoneLightbox = backlogHelper.getCreateEditMilestone();

            await createMilestoneLightbox.waitOpen();

            createMilestoneLightbox.delete();

            await utils.lightbox.confirm.ok();
            await browser.waitForAngular();

            let sprintName = createMilestoneLightbox.name().getAttribute('value');
            let sprintTitles = await backlogHelper.getSprintsTitles();

            expect(sprintTitles.indexOf(sprintName)).to.be.equal(-1);
        });
    });

    describe('tags', function() {
        it('show', function() {
            $('#show-tags').click();

            utils.common.takeScreenshot('backlog', 'backlog-tags');

            let tag = $$('.backlog-table .tag').get(0);

            expect(tag.isDisplayed()).to.be.eventually.true;
        });

        it('hide', function() {
            $('#show-tags').click();

            let tag = $$('.backlog-table .tag').get(0);

            expect(tag.isDisplayed()).to.be.eventually.false;
        });
    });

    describe('velocity forecasting', function() {
        it('show', async function() {
            browser.get(browser.params.glob.host + 'project/project-1/backlog');
            await utils.common.waitLoader();

            let usCount = await backlogHelper.userStories().count();

            await backlogHelper.openVelocityForecasting();
            utils.common.takeScreenshot('backlog', 'velocity-forecasting');

            let newUsCount = await backlogHelper.userStories().count();

            expect(newUsCount).is.below(usCount);
        });
        it('create sprint from forecasting',  async function() {
            browser.get(browser.params.glob.host + 'project/project-1/backlog');
            await utils.common.waitLoader();

            let sprintCount = await backlogHelper.sprintsOpen().count();

            backlogHelper.openVelocityForecasting();
            backlogHelper.createSprintFromForecasting();

            let newSprintCount = await backlogHelper.sprintsOpen().count();

            expect(sprintCount).is.below(newSprintCount);
        });
        it('hide forecasting if no velocity', async function() {
            browser.get(browser.params.glob.host + 'project/project-5/backlog');
            await utils.common.waitLoader();

            let forecasting = await backlogHelper.velocityForecasting();

            expect(forecasting).to.be.empty;
        });
    });

    describe('backlog filters', sharedFilters.bind(this, 'backlog', () => {
        return backlogHelper.userStories().count();
    }));

    describe('closed sprints', function() {
        async function createEmptyMilestone() {
            backlogHelper.openNewMilestone();

            let createMilestoneLightbox = backlogHelper.getCreateEditMilestone();

            await createMilestoneLightbox.waitOpen();

            createMilestoneLightbox.name().sendKeys('sprintName' + new Date().getTime());
            createMilestoneLightbox.submit();

            return createMilestoneLightbox.waitClose();
        }

        async function dragClosedUsToMilestone() {
            //create us
            backlogHelper.openNewUs();

            let createUSLightbox = backlogHelper.getCreateEditUsLightbox();

            await createUSLightbox.waitOpen();

            createUSLightbox.subject().sendKeys('subject');

            //closed status
            createUSLightbox.status(5).click();

            createUSLightbox.submit();

            await utils.lightbox.close(createUSLightbox.el);

            await backlogHelper.loadFullBacklog();

            // drag us to milestone
            let dragElement =  backlogHelper.userStories().last();
            let dragElementHandler = dragElement.$('.icon-drag');

            let sprint = backlogHelper.getClosedSprintTable();
            await utils.common.drag(dragElementHandler, sprint);

            return browser.waitForAngular();
        }

        before(async function() {
            await createEmptyMilestone();
            await dragClosedUsToMilestone();
        });

        it('open closed sprints', async function() {
            backlogHelper.toggleClosedSprints();

            let closedSprints = await backlogHelper.closedSprints().count();

            expect(closedSprints).to.be.equal(1);
        });

        it('close closed sprints', async function() {
            backlogHelper.toggleClosedSprints();

            let closedSprints = await backlogHelper.closedSprints().count();

            expect(closedSprints).to.be.equal(0);
        });

        it('open sprint by drag open US to closed sprint', async function() {
            backlogHelper.toggleClosedSprints();

            await backlogHelper.setUsStatus(1, 1);

            let dragElement =  backlogHelper.userStories().get(1);
            let dragElementHandler = dragElement.$('.icon-drag');

            let sprint = backlogHelper.sprints().last();

            await backlogHelper.toggleSprint(sprint);

            await utils.common.drag(dragElementHandler, sprint.$('.sprint-table'));
            await browser.waitForAngular();

            let closedSprints = await $('.filter-closed-sprints').isPresent();

            expect(closedSprints).to.be.false;
        });
    });
});
