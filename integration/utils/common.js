var common = module.exports;

var fs = require('fs');

common.hasClass = async function (element, cls) {
    let classes = await element.getAttribute('class');

    return classes.split(' ').indexOf(cls) !== -1;
};

common.waitLoader = function () {
    let el = $(".loader");

   return browser.wait(async function() {
        let active = await common.hasClass(el, 'active');

       return !active;
    }, 5000);
};

common.takeScreenshot = async function (section, filename) {
    let screenshotsFolder = __dirname + "/../screenshots/";
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
        let count = await element.all(by.css('.ui-sortable-helper')).count()

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
        })
};
