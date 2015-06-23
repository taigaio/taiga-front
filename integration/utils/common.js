var common = module.exports;

var fs = require('fs');

common.hasClass = function (element, cls) {
    return element.getAttribute('class').then(function (classes) {
        return classes.split(' ').indexOf(cls) !== -1;
    });
};

common.waitLoader = function () {
    var el = $(".loader");

   return browser.wait(function() {
        return common.hasClass(el, 'active').then(function(active) {
            return !active;
        });
    }, 5000);
};

common.takeScreenshot = function (section, filename) {
    var screenshotsFolder = __dirname + "/../screenshots/";
    var dir = screenshotsFolder + section + "/";

    if (!fs.existsSync(screenshotsFolder)) {
        fs.mkdirSync(screenshotsFolder);
    }

    return browser.takeScreenshot().then(function (data) {
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir);
        }

        var path = dir + filename + ".png";
        var stream = fs.createWriteStream(path);

        stream.write(new Buffer(data, 'base64'));
        stream.end();
    });
};

common.closeCookies = function() {
    return browser.executeScript(function() {
        document.cookie='cookieConsent=1';
    });
};

// common.waitLoad = function() {
//     var deferred = protractor.promise.defer();

//     common.waitLoader().then(function() {
//         deferred.fulfill();
//     });

//     return deferred.promise;
// };

common.login = function(username, password) {
    browser.get('http://localhost:9001/login');

    $('input[name="username"]').sendKeys(username);
    $('input[name="password"]').sendKeys(password);

    $('.submit-button').click();

    return browser.driver.wait(function() {
        return browser.driver.getCurrentUrl().then(function(url) {
            return url === 'http://localhost:9001/';
        });
    }, 10000);
};

common.prepare = function() {
    browser.get('http://localhost:9001/');

    return common.closeCookies()
}

common.dragEnd = function(elm) {
    return browser.wait(function() {
        return element.all(by.css('.ui-sortable-helper')).count()
            .then(function(count) {
                return count === 0;
            });
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
