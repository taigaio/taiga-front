/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var exports = module.exports = {};
var fs = require("fs");
var gutil = require('gulp-util');

var Theme = function() {
    var defaultTheme = "taiga";

    var themesPath = "app/themes";
    var tmpThemesPath = "tmp/themes";

    var themesSequenceIndex = 0;
    var themesSequence = [];

    var searchIndex = function(name) {
        for(var i = 0; i < themesSequence.length; i++) {
            if (themesSequence[i].name === name) {
                return i;
            }
        }
    };

    var initThemes = function () {
        var availableThemes = {};
        var files = fs.readdirSync(themesPath);

        files.forEach(function(file) {
            var path = themesPath + '/' + file;
            var tmpPath = tmpThemesPath + '/' + file;

            if (fs.statSync(path).isDirectory()) {
                availableThemes[file] = {
                    name: file,
                    path: path,
                    customVariables: path + "/variables.scss",
                    customScss: path + "/custom.scss",
                    customCss: tmpPath + "/custom.css",
                };
            }
        });

        themesSequence.push(availableThemes[defaultTheme]);

        for (var theme in availableThemes) {
            if (theme !== defaultTheme) {
                themesSequence.push(availableThemes[theme]);
            }
        }
    };

    initThemes();

    var obj = {};

    obj.next = function() {
        themesSequenceIndex++;
    };

    obj.set = function(name) {
        themesSequenceIndex = searchIndex(name);
    };

    Object.defineProperty(obj, "current", {
        get: function() {
            return themesSequence[themesSequenceIndex];
        }
    });

    Object.defineProperty(obj, "availableThemes", {
        get: function() {
            return themesSequence;
        }
    });

    obj.size = themesSequence.length;

    return obj;
};

exports.themes = {
    sequence: function() {
        return Theme();
    }
};

exports.unusedCss = function(options) {
    var through = require('through2');
    var css = require('css');
    var path = require('path');


    var content = fs.readFileSync(options.css, "utf8");
    var ast = css.parse(content, {});

    var files = [];

    var validsSelectors = [];

    ast.stylesheet.rules.forEach(function(rule) {
        if (rule.selectors) {
            rule.selectors.forEach(function(selectorRule) {
                var selectors = selectorRule.split(" ");

                selectors.forEach(function(selector) {
                    var valid = false;

                    if (selector.slice(0, 2) === 'tg') {
                        valid = true;
                    } else if (selector[0] === '.') {
                        valid = true;

                        selector = '.' + selector.split('.')[1]; // '.class1.class2 -> .class1'
                    }

                    selector = selector.split('::')[0];
                    selector = selector.split(':')[0];

                    if(valid && validsSelectors.indexOf(selector) === -1) {
                        validsSelectors.push(selector);
                    }
                });
            });
        }
    });

    var addFile = function(file, encoding, cb) {
        files.push(file);
        cb();
    };

    var searchUnusedCss = function(cb) {
        var invalid = [];

        validsSelectors.forEach(function(validSelector) {
            var finded = false;

            files.every(function(file) {
                var content = file.contents.toString();
                var ext = path.extname(file.path);
                var pattern = validSelector;

                if (ext === '.html') {
                    pattern = validSelector.slice(1);
                }

                if(content.indexOf(pattern) !== -1) {
                    finded = true;

                    return false;
                }

                return true;
            });

            if (!finded) {
                invalid.push(validSelector);
            }
        });


        for(var i = 0; i < invalid.length; i++) {
            gutil.log(gutil.colors.magenta(invalid[i]));
        }

        cb();
    };

    return through.obj(addFile, searchUnusedCss);
};
