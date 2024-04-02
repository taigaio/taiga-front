/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var common = module.exports;

var fs = require('fs');
var uuid = require('node-uuid');
var path = require('path');

common.getElm = function(el) {
    var deferred = protractor.promise.defer();

    if (typeof el === 'string' || el instanceof String) {
        browser.wait(function() {
            return browser.isElementPresent($(el).locator());
        }, 4000).then(() => {
            deferred.fulfill($(el));
        });
    } else {
        deferred.fulfill($(el));
    }

    return deferred.promise;
};

common.waitElementNotPresent = function(el) {
    return browser.wait(function() {
        return el.isPresent().then(function(present) {
            return !present;
        });
    });
};

common.waitElementPresent = function(el) {
    return browser.wait(function() {
        return el.isPresent();
    });
};

common.hasClass = async function (element, cls) {
    let classes = await element.getAttribute('class');

    return classes.split(' ').indexOf(cls) !== -1;
};

common.isBrowser = function(browserName) {
    return browserName === browser.browserName;
};

common.browserSkip = function(browserName, name, fn) {
    if( typeof browserName === 'string') {
        if (browser.browserName !== browserName) {
            return it.call(this, name, fn);
        } else {
            return it.skip.call(this, name, fn);
        }
    } else {
        if (browserName.indexOf(browser.browserName) === -1) {
            return it.call(this, name, fn);
        } else {
            return it.skip.call(this, name, fn);
        }
    }
};

common.waitHref = async function(el) {
    await browser.wait(async function() {
        let href = await el.getAttribute('href');

        return (href.length > 1 && href !== browser.params.glob.host + "#");
     }, 5000);

    return el.getAttribute('href');
};

common.link = async function(el) {
    let oldUrl = await browser.getCurrentUrl();

    await browser
        .actions()
        .mouseMove(el)
        .perform();

    // Ugly hack for firefox:
    // In firefox if we have a href split in two lines the point where the cursor
    // is located is just in the middle of the two lines and the hover events
    // aren't fired (we need them for the tg-nav calculation). Moving the cursor
    // "a little bit" tries to ensure the href text is really hovered and the
    // events are fired
    await browser.actions()
        .mouseMove({x: -10, y: -10})
        .perform();

    await browser.actions()
        .mouseMove({x: 10, y: 10})
        .perform();

    await common.waitHref(el);

    await browser
        .actions()
        .mouseMove(el)
        .click()
        .perform();

    return browser.wait(async function() {
        let newUrl = await browser.getCurrentUrl();

        return oldUrl !== newUrl;
    }, 5000);
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

    let browserName = browser.browserName;

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
    browser.get(browser.params.glob.host + 'login');

    $('input[name="username"]').sendKeys(username);
    $('input[name="password"]').sendKeys(password);

    $('.submit-button').click();

    return browser.driver.wait(async function() {
        let url =  await browser.driver.getCurrentUrl();

        return url === browser.params.glob.host;
    }, 10000).then(function() {
        return common.closeJoyride();
    });
};

common.logout = async function() {
    let dropdown = $('div[tg-dropdown-user]');

    await browser.actions()
        .mouseMove(dropdown)
        .perform();

    await common.waitTransitionTime(dropdown);

    $$('.navbar-dropdown li a').last().click();

    return browser.driver.wait(async function() {
        let url =  await browser.driver.getCurrentUrl();
        return url === browser.params.glob.host + 'discover';
    }, 10000);
};

common.prepare = function() {
    browser.get(browser.params.glob.host);

    return common.closeCookies();
};

common.dragEnd = function(elm) {
    return browser.wait(async function() {
        let count = await $$('.gu-mirror').count();

        return count === 0;
    }, 5000);
};

common.drag = async function(elm, elm2, extrax = 0, extray = 0) {
    var drag = `
        var drag = arguments[0].origin;
        var dest = arguments[0].dest;
        var extrax = arguments[0].extrax;
        var extray = arguments[0].extray;

        function isScrolledIntoView(el) {
            var elemTop = el.getBoundingClientRect().top;
            var elemBottom = el.getBoundingClientRect().bottom;

            var isVisible = (elemTop >= 0) && (elemBottom <= window.innerHeight);
            return isVisible;
        }

        function triggerMouseEvent (node, eventType, opts) {
            var event = new CustomEvent(eventType);
            event.initEvent (eventType, true, true);

            if(opts && opts.cords) {
                event.pageX = opts.cords.x;
                event.clientX = opts.cords.x;
                event.pageY = opts.cords.y;
                event.clientY = opts.cords.y - window.pageYOffset;
                dest.scrollIntoView();
            }

            event.which = 1;

            node.dispatchEvent(event);
        }

        if (!isScrolledIntoView(drag)) {
            drag.scrollIntoView();
        }

        triggerMouseEvent(drag, "mousedown");

        triggerMouseEvent(document.documentElement, "mousemove", {
            cords: {
                x: $(dest).offset().left + extrax,
                y: $(dest).offset().top + extray
            }
        });

        if (!isScrolledIntoView(dest)) {
            dest.scrollIntoView();
        }

        triggerMouseEvent(document.documentElement, "mousemove", {
            cords: {
                x: $(dest).offset().left + extrax,
                y: $(dest).offset().top + extray
            }
        });

        triggerMouseEvent(document.documentElement, "mouseup", {
            cords: {
                x: $(dest).offset().left + extrax,
                y: $(dest).offset().top + extray
            }
        });
    `;

    return browser.executeScript(drag, {
        origin: elm.getWebElement(),
        dest: elm2.getWebElement(),
        extrax: extrax,
        extray: extray
    }).then(common.dragEnd);
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

    let html = await el.getAttribute('outerHTML');

    return function() {
       return browser.wait(async function() {
           let newhtml = await el.getAttribute('outerHTML');

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

    let html = await el.getAttribute('innerHTML');

    return function() {
       return browser.wait(async function() {
           let newhtml = await el.getAttribute('outerHTML');

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
    browser.get(browser.params.glob.host);

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
        $(arguments[0]).removeClass('hidden');
    };

    await browser.executeScript(toggleInput, inputFile.getWebElement());

    await inputFile.sendKeys(filePath);
    await browser.executeScript(toggleInput, inputFile.getWebElement());
};

common.getMenu = function() {
    return $('div[tg-dropdown-user]');
};

common.topMenuOption = async function(option) {
    let menu = common.getMenu();
    let menuOption = menu.$$('li a').get(option);
    browser.actions().mouseMove(menu).perform();
    return browser.actions().mouseMove(menuOption).click().perform();
};

common.getProjectUrlRoot = async function() {
    let url =  await browser.driver.getCurrentUrl();

    return browser.params.glob.host + url.split('/').slice(3, 5).join('/');
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

common.uploadFilePath = function() {
    if (browser.inWindows()) {
        return browser.params.glob.attachments.windows;
    } else {
        return path.resolve(process.cwd(), 'e2e', browser.params.glob.attachments.unix);
    }
};

common.uploadImagePath = function() {
    if (browser.inWindows()) {
        return browser.params.glob.attachments.windowsImg;
    } else {
        return path.resolve(process.cwd(), 'e2e', browser.params.glob.attachments.unixImg);
    }
};

common.closeJoyride = async function() {
    await browser.waitForAngular();

    let present = await $('.introjs-skipbutton').isPresent();

    if (present) {
        $('.introjs-skipbutton').click();
        await browser.sleep(600);
    }
};

common.createProject = async function(members = []) {
    var createProjectHelper = require('../helpers/create-project-helper');
    var newProjectScreen = createProjectHelper.newProjectScreen();

    browser.get(browser.params.glob.host + 'project/new');
    await common.waitLoader();
    await newProjectScreen.selectScrumOption();
    let projectName = 'name ' + Date.now();
    let projectDescription = 'description ' + Date.now();
    await newProjectScreen.fillNameAndDescription(projectName, projectDescription);
    await newProjectScreen.createProject();
    let projectUrl = await browser.getCurrentUrl()
    let projectSlug = projectUrl.split('/')[4];

    if (members.length) {
        var adminMembershipsHelper = require('../helpers').adminMemberships;

        let url = await browser.getCurrentUrl();
        url = url.split('/');
        url = browser.params.glob.host + '/project/' + url[4] + '/admin/memberships';

        browser.get(url);
        await common.waitLoader();

        let newMemberLightbox = adminMembershipsHelper.getNewMemberLightbox();
        adminMembershipsHelper.openNewMemberLightbox();

        await newMemberLightbox.waitOpen();

        for(var i = 0; i < members.length; i++) {
            newMemberLightbox.newEmail(members[i]);
            newMemberLightbox.setRole(0);
        }

        newMemberLightbox.submit();

        await newMemberLightbox.waitClose();
    }
    return projectSlug;
};

common.getTransferProjectToken = function(projectSlug, username) {
    let execSync = require('child_process').execSync;

    let cliPath = path.resolve(process.cwd(), 'e2e', 'taiga_back_cli.py');

    let result = execSync(`python ${cliPath} transfer_token ${browser.params.glob.back} ${projectSlug}  ${username}`);

    return result.toString();
};


/*
max_private_projects
max_memberships_private_projects
max_public_projects
max_memberships_public_projects
*/
common.setUserLimits = function(username, restrictions) {
    let execSync = require('child_process').execSync;

    let cliPath = path.resolve(process.cwd(), 'e2e', 'taiga_back_cli.py');
    let params = '';

    for (let restrictionKey in restrictions) {
        params += `--${restrictionKey}=${restrictions[restrictionKey]} `;
    }

    execSync(`python ${cliPath} update_user_limits ${browser.params.glob.back} ${username} ${params}`);
};
