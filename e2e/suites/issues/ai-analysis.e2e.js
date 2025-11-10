/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('AI Analysis Feature', function() {
    
    before(async function() {
        // 导航到 Issues 页面
        browser.get(browser.params.glob.host + 'project/project-3/issues');
        await browser.waitForAngular();
    });

    describe('AI Analysis Button', function() {
        
        it('should display AI analysis button', async function() {
            let aiButton = $('.btn-ai-analysis');
            await expect(aiButton.isPresent()).to.eventually.be.true;
            
            utils.common.takeScreenshot('issues', 'ai-analysis-button');
        });

        it('should have correct button text', async function() {
            let aiButton = $('.btn-ai-analysis');
            let buttonText = await aiButton.getText();
            
            // 根据当前语言，应该是 "AI 分析" 或 "AI Analysis"
            expect(buttonText).to.match(/AI.*分析|AI.*Analysis/i);
        });

        it('should be clickable', async function() {
            let aiButton = $('.btn-ai-analysis');
            await expect(aiButton.isEnabled()).to.eventually.be.true;
        });
    });

    describe('AI Analysis Lightbox', function() {
        
        before(async function() {
            // 点击 AI 分析按钮
            let aiButton = $('.btn-ai-analysis');
            await aiButton.click();
            
            // 等待 Loading 完成（模拟数据需要 1.5 秒）
            await browser.sleep(2000);
        });

        it('should open lightbox after clicking button', async function() {
            let lightbox = $('.lightbox-ai-analysis');
            await expect(lightbox.isPresent()).to.eventually.be.true;
            await expect(lightbox.isDisplayed()).to.eventually.be.true;
            
            utils.common.takeScreenshot('issues', 'ai-analysis-lightbox');
        });

        it('should display lightbox title', async function() {
            let title = $('.lightbox-ai-analysis .lightbox-title');
            let titleText = await title.getText();
            
            expect(titleText).to.match(/AI.*Issue.*分析结果|AI.*Issue.*Analysis.*Results/i);
        });

        it('should display analysis count', async function() {
            let subtitle = $('.lightbox-ai-analysis .lightbox-subtitle');
            await expect(subtitle.isPresent()).to.eventually.be.true;
            
            let subtitleText = await subtitle.getText();
            expect(subtitleText).to.match(/\d+/); // 应该包含数字
        });

        it('should display issue cards', async function() {
            let cards = $$('.ai-issue-card');
            let cardCount = await cards.count();
            
            expect(cardCount).to.be.greaterThan(0);
        });

        it('should display all required fields in each card', async function() {
            let firstCard = $('.ai-issue-card').first();
            
            // Issue 标题
            let issueTitle = firstCard.$('.ai-issue-header');
            await expect(issueTitle.isPresent()).to.eventually.be.true;
            
            // 置信度
            let confidence = firstCard.$('.ai-confidence');
            await expect(confidence.isPresent()).to.eventually.be.true;
            
            // 优先级
            let priority = firstCard.$('.ai-badge.priority');
            await expect(priority.isPresent()).to.eventually.be.true;
            
            // 类型
            let type = firstCard.$('.ai-badge.type');
            await expect(type.isPresent()).to.eventually.be.true;
            
            // 严重程度
            let severity = firstCard.$('.ai-badge.severity');
            await expect(severity.isPresent()).to.eventually.be.true;
            
            // 描述
            let description = firstCard.$('.ai-analysis-description');
            await expect(description.isPresent()).to.eventually.be.true;
            
            // 相关模块
            let modules = firstCard.$('.ai-related-modules');
            await expect(modules.isPresent()).to.eventually.be.true;
            
            // 解决方案
            let solutions = firstCard.$('.ai-solutions');
            await expect(solutions.isPresent()).to.eventually.be.true;
            
            utils.common.takeScreenshot('issues', 'ai-analysis-card-details');
        });

        it('should display priority badge with correct color', async function() {
            let priorityBadge = $('.ai-issue-card').first().$('.ai-badge.priority');
            let badgeClass = await priorityBadge.getAttribute('class');
            
            // 应该包含优先级相关的 class
            expect(badgeClass).to.match(/priority-(low|normal|high)/i);
        });

        it('should display 2-4 related modules', async function() {
            let modulesList = $('.ai-issue-card').first().$$('.ai-related-modules li');
            let modulesCount = await modulesList.count();
            
            expect(modulesCount).to.be.at.least(2);
            expect(modulesCount).to.be.at.most(4);
        });

        it('should display 3-5 solutions', async function() {
            let solutionsList = $('.ai-issue-card').first().$$('.ai-solutions li');
            let solutionsCount = await solutionsList.count();
            
            expect(solutionsCount).to.be.at.least(3);
            expect(solutionsCount).to.be.at.most(5);
        });

        it('should close lightbox when clicking close button', async function() {
            let closeButton = $('.lightbox-ai-analysis .lightbox-close');
            await closeButton.click();
            
            await browser.sleep(500); // 等待关闭动画
            
            let lightbox = $('.lightbox-ai-analysis');
            await expect(lightbox.isDisplayed()).to.eventually.be.false;
            
            utils.common.takeScreenshot('issues', 'ai-analysis-closed');
        });
    });

    describe('Error Handling', function() {
        
        it('should show error when no issues are present', async function() {
            // 这个测试需要在没有 Issues 的项目中运行
            // 或者需要模拟空列表的情况
            
            // 暂时跳过，等待实现
            this.skip();
        });

        it('should handle API errors gracefully', async function() {
            // 这个测试需要模拟 API 错误
            // 暂时跳过，等待后端集成
            
            this.skip();
        });
    });

    describe('Multiple Issues Analysis', function() {
        
        before(async function() {
            // 确保页面上有多个 Issues
            browser.get(browser.params.glob.host + 'project/project-3/issues');
            await browser.waitForAngular();
        });

        it('should analyze all visible issues', async function() {
            // 获取当前页面的 Issues 数量
            let issueRows = $$('.issues-table .row');
            let issueCount = await issueRows.count();
            
            // 点击 AI 分析
            let aiButton = $('.btn-ai-analysis');
            await aiButton.click();
            await browser.sleep(2000);
            
            // 验证分析结果数量
            let cards = $$('.ai-issue-card');
            let cardCount = await cards.count();
            
            expect(cardCount).to.equal(issueCount);
        });

        it('should display each issue only once', async function() {
            let cards = $$('.ai-issue-card');
            let issueRefs = [];
            
            for (let i = 0; i < await cards.count(); i++) {
                let card = cards.get(i);
                let header = await card.$('.ai-issue-header').getText();
                let ref = header.match(/#\d+/)[0]; // 提取 #42 这样的编号
                
                // 检查是否重复
                expect(issueRefs).to.not.include(ref);
                issueRefs.push(ref);
            }
        });
    });

    describe('Internationalization', function() {
        
        it('should display Chinese text when locale is zh-hans', async function() {
            // 切换到中文
            // 需要根据你的项目实现来调整
            
            browser.get(browser.params.glob.host + 'project/project-3/issues?locale=zh-hans');
            await browser.waitForAngular();
            
            let aiButton = $('.btn-ai-analysis');
            let buttonText = await aiButton.getText();
            
            expect(buttonText).to.include('分析');
            
            await aiButton.click();
            await browser.sleep(2000);
            
            let title = $('.lightbox-ai-analysis .lightbox-title');
            let titleText = await title.getText();
            
            expect(titleText).to.include('分析结果');
        });

        it('should display English text when locale is en', async function() {
            browser.get(browser.params.glob.host + 'project/project-3/issues?locale=en');
            await browser.waitForAngular();
            
            let aiButton = $('.btn-ai-analysis');
            let buttonText = await aiButton.getText();
            
            expect(buttonText).to.match(/analysis/i);
            
            await aiButton.click();
            await browser.sleep(2000);
            
            let title = $('.lightbox-ai-analysis .lightbox-title');
            let titleText = await title.getText();
            
            expect(titleText).to.match(/analysis.*results/i);
        });
    });
});
