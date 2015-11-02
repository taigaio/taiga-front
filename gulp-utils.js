var exports = module.exports = {};
var fs = require("fs");

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

    return obj;
};

exports.themes = {
    sequence: function() {
        return Theme();
    }
};
