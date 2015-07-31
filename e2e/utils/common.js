var common = module.exports;

var fs = require('fs');
var uuid = require('node-uuid');
var path = require('path');

common.hasClass = async function (element, cls) {
    let classes = await element.getAttribute('class');

    return classes.split(' ').indexOf(cls) !== -1;
};

common.isBrowser = async function(browserName) {
    let cap = await browser.getCapabilities();

    return browserName === cap.caps_.browserName;
};

common.browserSkip = function(browserName, name, fn) {
    if (browser.browserName !== browserName) {
        return it.call(this, name, fn);
    } else {
        return it.skip.call(this, name, fn);
    }
};

common.link = async function(el) {
    await browser.actions().mouseMove(el).perform();

    await el.click();
};

common.waitLoader = function () {
    let el = $(".loader");

   return browser.wait(async function() {
        let active = await common.hasClass(el, 'active');

       return !active;
    }, 5000);
};

common.takeScreenshot = async function (section, filename) {
    await common.waitRequestAnimationFrame();

    let cap = await browser.getCapabilities();
    let browserName = cap.caps_.browserName;

    let screenshotsFolder = __dirname + "/../screenshots/" + browserName + "/";
    let dir = screenshotsFolder + section + "/";

    if (!fs.existsSync(screenshotsFolder)) {
        fs.mkdirSync(screenshotsFolder);
    }

    let data = await browser.takeScreenshot();

    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    let path = dir + filename + ".png";
    let stream = fs.createWriteStream(path);

    stream.write(new Buffer(data, 'base64'));
    stream.end();
};

common.closeCookies = function() {
    return browser.executeScript(function() {
        document.cookie='cookieConsent=1';
    });
};

common.login = function(username, password) {
    browser.get('http://localhost:9001/login');

    $('input[name="username"]').sendKeys(username);
    $('input[name="password"]').sendKeys(password);

    $('.submit-button').click();

    return browser.driver.wait(async function() {
        let url =  await browser.driver.getCurrentUrl();

        return url === 'http://localhost:9001/';
    }, 10000);
};

common.prepare = function() {
    browser.get('http://localhost:9001/');

    return common.closeCookies()
}

common.dragEnd = function(elm) {
    return browser.wait(async function() {
        let count = await $$('.ui-sortable-helper').count();

        return count === 0;
    }, 1000);
};

common.drag = function(elm, location) {
    return browser
        .actions()
        .dragAndDrop(elm, location)
        .perform()
        .then(function() {
            return common.dragEnd();
        });
};

common.transitionend = function(selector, property) {
    let script = `
        window.e2e = {};

        var callback = arguments[1];
        var property = arguments[0];
        var sel = document.querySelector('${selector}');

        var listener = function(event) {
            var finish = function() {
                window.e2e.transition = false;
                sel.removeEventListener('transitionend', listener);
                callback();
            };

            if (property) {
                if(event.propertyName === property) {
                    finish();
                }
            } else {
                finish();
            }
        };

        window.e2e.transition = true;

        sel.addEventListener('transitionend', listener);
    `;

    browser.executeScript(script, property);

    return function() {
        return browser.wait(async function() {
            let ts = await browser.executeScript(function() {
                return window.e2e.transition === false;
            });

            return ts;
        }, 5000);
    };
};

common.waitTransitionTime = async function(el) {
    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

    let transition = await el.getCssValue('transition-duration');
    let transitionDelay = await el.getCssValue('transition-delay');

    let time = parseFloat(transition.replace('s', '')) * 1000;
    let timeDelay = parseFloat(transitionDelay.replace('s', '')) * 1000;

    return browser.sleep(time + timeDelay);
};

common.waitRequestAnimationFrame = function() {
    let script = `
        var requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame ||
            window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;

        var callback = arguments[0];

        requestAnimationFrame(callback);
    `;

    return browser.executeAsyncScript(script);
};

common.outerHtmlChanges = async function(el='body') {
    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

    let html = await el.getOuterHtml();

    return function() {
       return browser.wait(async function() {
           let newhtml = await el.getOuterHtml();

           return html !== newhtml;
        }, 5000).then(function() {
            return common.waitRequestAnimationFrame();
        });
    };
}

common.innerHtmlChanges = async function(el='body') {
    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

    let html = await el.getInnerHtml();

    return function() {
       return browser.wait(async function() {
           let newhtml = await el.getOuterHtml();

           return html !== newhtml;
        }, 5000).then(function() {
            return common.waitRequestAnimationFrame();
        });
    };
};

common.clear = function(elem, length) {
    length = length || 100;
    let backspaceSeries = '';

    for (var i = 0; i < length; i++) {
        backspaceSeries += protractor.Key.BACK_SPACE;
    }

    return elem.sendKeys(backspaceSeries);
};

common.goHome = async function() {
    browser.get('http://localhost:9001');

    await common.waitLoader();
};

common.goToFirstProject = async function() {
    await browser.actions().mouseMove($('div[tg-dropdown-project-list]')).perform();

    let project = $$('div[tg-dropdown-project-list] li a').first();

    await common.link(project);

    await common.waitLoader();
};

common.goToIssues = async function() {
    await common.link($('#nav-issues a'));

    await common.waitLoader();
};

common.goToFirstIssue = async function() {
    let issue = $$('section.issues-table .row.table-main .subject a').first();

    await common.link(issue);

    await common.waitLoader();
};

common.uploadFile = async function(inputFile, filePath) {
    let toggleInput = function() {
        $(arguments[0]).toggle();
    };

    let absolutePath = path.resolve(process.cwd(), 'e2e', filePath);

    await browser.executeScript(toggleInput, inputFile.getWebElement());
    await inputFile.sendKeys(absolutePath);
    await browser.executeScript(toggleInput, inputFile.getWebElement());
};

common.topMenuOption = async function(option) {
    let menu = $('div[tg-dropdown-user]');

    await browser.actions().mouseMove(menu).perform();

    return menu.$$('li').get(option).click();
};

common.goToBacklog = async function() {
    await common.link($('#nav-backlog a'));

    await common.waitLoader();
}

common.goToFirstUserStory = async function() {
    await common.link($$('.user-story-name>a').first());

    await common.waitLoader();
}

common.goToFirstSprint = async function() {
    await common.link($$('div[tg-backlog-sprint] a.button-gray').first());

    await common.waitLoader();
}

common.goToFirstTask = async function() {
    await common.link($$('div[tg-taskboard-task] a.task-name').first());

    await common.waitLoader();
}
