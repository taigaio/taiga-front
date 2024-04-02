/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

////////////////////////////////////////////////
// Protractor Browser Capabilities Extensions //
////////////////////////////////////////////////
"use strict";

module.exports = browser.getCapabilities().then(function(s) {
    var browserName, browserVersion;
    var shortName, shortVersion;
    var ie, ff, ch, sa;
    var platform;

    var capabilities = {};

    for(let item of s) {
        capabilities[item[0]] = item[1];
    }

    platform = capabilities.platform;
    browserName = capabilities.browserName;
    browserVersion = capabilities.version;
    shortVersion = browserVersion.split('.')[0];

    browser.browserName = browserName;

    ie = /i.*explore/.test(browserName);
    ff = /firefox/.test(browserName);
    ch = /chrome/.test(browserName);
    sa = /safari/.test(browserName);

    if (ie) {
        shortName = 'ie';
    } else if (ff) {
        shortName = 'ff';
    } else if (ch) {
        shortName = 'ch';
    } else if (sa) {
        shortName = 'sa';
    } else {
        throw new Exception('Unsupported browser: '+ browserName);
    };

    // Returns one of these: ['ch', 'ff', 'sa', 'ie']
    browser.getShortBrowserName = function() {
        return shortName;
    };

    // Returns one of these: ['ch33', 'ff27', 'sa7', 'ie11', 'ie10', 'ie9']
    browser.getShortNameVersionAll = function() {
        return shortName + shortVersion;
    };

    // Returns one of these: ['ch', 'ff', 'sa', 'ie11', 'ie10', 'ie9']
    browser.getShortNameVersion = function() {
        if (ie) {
            return shortName + shortVersion;
        } else {
            return shortName;
        };
    };

    // Return if current browser is IE, optionally specifying if it is a particular IE version
    browser.isInternetExplorer = function(ver) {
        if (ver == null) {
            return ie;
        } else {
            return ie && ver.toString() === shortVersion;
        }
    };

    // Function alias
    browser.isIE = browser.isInternetExplorer;

    browser.isSafari = function() {
        return sa;
    };

    browser.isFirefox = function() {
        return ff;
    };

    // Return if current browser is Chrome, optionally specifying if it is a particular Chrome version
    browser.isChrome = function(ver) {
        if (ver == null) {
            return ch;
        } else {
            return ch && ver.toString() === shortVersion;
        }
    };

    browser.inWindows = function() {
        return /^WIN|XP/.test(platform);
    };

    browser.inOSX = function() {
        return /^MAC/.test(platform);
    };

    // Save current webdriver session id for later use
    browser.webdriverRemoteSessionId = capabilities['webdriver.remote.sessionid'];

    browser.inSauceLabs = function() {
        return !!(browser.params.inSauceLabs);
    };

    browser.inBrowserStack = function() {
        return !!(browser.params.inBrowserStack);
    };

    browser.inTheCloud = function() {
        return !!(browser.params.inSauceLabs || browser.params.inBrowserStack);
    };
});
