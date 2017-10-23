var gulp = require("gulp"),
    fs = require('fs'),
    imagemin = require("gulp-imagemin"),
    jade = require("gulp-jade"),
    coffee = require("gulp-coffee"),
    concat = require("gulp-concat"),
    uglify = require("gulp-uglify"),
    plumber = require("gulp-plumber"),
    wrap = require("gulp-wrap"),
    rename = require("gulp-rename"),
    flatten = require("gulp-flatten"),
    gulpif = require("gulp-if"),
    replace = require("gulp-replace"),
    sass = require("gulp-sass"),
    csslint = require("gulp-csslint"),
    minifyCSS = require("gulp-minify-css"),
    scsslint = require("gulp-scss-lint"),
    cache = require("gulp-cache"),
    cached = require("gulp-cached"),
    jadeInheritance = require("gulp-jade-inheritance"),
    sourcemaps = require("gulp-sourcemaps"),
    insert = require("gulp-insert"),
    autoprefixer = require("gulp-autoprefixer"),
    templateCache = require("gulp-angular-templatecache"),
    runSequence = require("run-sequence"),
    order = require("gulp-order"),
    print = require('gulp-print'),
    del = require("del"),
    livereload = require('gulp-livereload'),
    gulpFilter = require('gulp-filter'),
    mergeStream = require('merge-stream'),
    path = require('path'),
    addsrc = require('gulp-add-src'),
    jsonminify = require('gulp-jsonminify'),
    classPrefix = require('gulp-class-prefix'),
    coffeelint = require('gulp-coffeelint');

var argv = require('minimist')(process.argv.slice(2));

var utils = require("./gulp-utils");

var themes = utils.themes.sequence();

if (argv.theme) {
    themes.set(argv.theme);
}

var version = "v-" + Date.now();

var paths = {};
paths.app = "app/";
paths.dist = "dist/";
paths.distVersion = paths.dist + version + "/";
paths.tmp = "tmp/";
paths.extras = "extras/";
paths.modules = "node_modules/";

paths.jade = [
    paths.app + "**/*.jade"
];

paths.htmlPartials = [
    paths.tmp + "partials/**/*.html",
    paths.tmp + "modules/**/*.html",
    "!" + paths.tmp + "partials/includes/**/*.html",
    "!" + paths.tmp + "/modules/**/includes/**/*.html"
];

paths.images = paths.app + "images/**/*";
paths.svg = paths.app + "svg/**/*";
paths.css_vendor = [
    paths.modules + "intro.js/introjs.css",
    paths.modules + "dragula/dist/dragula.css",
    paths.modules + "awesomplete/awesomplete.css",
    paths.app + "styles/vendor/*.css",
    paths.modules + "medium-editor/dist/css/medium-editor.css",
    paths.modules + "medium-editor/dist/css/themes/default.css",
    paths.modules + "prismjs/themes/prism-okaidia.css"
];
paths.locales = paths.app + "locales/**/*.json";
paths.modulesLocales = paths.app + "modules/**/locales/*.json";

paths.sass = [
    paths.app + "**/*.scss",
    "!" + paths.app + "**/*.mixin.scss",
    "!" + paths.app + "styles/bourbon/**/*.scss",
    "!" + paths.app + "styles/dependencies/**/*.scss",
    "!" + paths.app + "styles/extras/**/*.scss",
    "!" + paths.app + "themes/**/*.scss",
];

paths.sass_watch = paths.sass.concat(themes.current.customScss);

paths.styles_dependencies = [
    paths.app + "/styles/dependencies/**/*.scss",
    themes.current.customVariables
];

paths.css = [
    paths.tmp + "styles/**/*.css",
    paths.tmp + "modules/**/*.css",
    paths.tmp + "custom.css"
];

paths.css_order = [
    paths.tmp + "styles/vendor/*",
    paths.tmp + "styles/core/reset.css",
    paths.tmp + "styles/core/base.css",
    paths.tmp + "styles/core/typography.css",
    paths.tmp + "styles/core/animation.css",
    paths.tmp + "styles/core/elements.css",
    paths.tmp + "styles/core/forms.css",
    paths.tmp + "styles/layout/*",
    paths.tmp + "styles/components/*",
    paths.tmp + "styles/modules/**/*.css",
    paths.tmp + "modules/**/*.css",
    paths.tmp + "styles/shame/*.css",
    paths.tmp + "custom.css"
];

paths.coffee = [
    paths.app + "**/*.coffee",
    "!" + paths.app + "**/*.spec.coffee",
];

paths.coffee_order = [
    paths.app + "modules/compile-modules/**/*.module.coffee",
    paths.app + "modules/compile-modules/**/*.coffee",
    paths.app + "coffee/app.coffee",
    paths.app + "coffee/*.coffee",
    paths.app + "coffee/modules/controllerMixins.coffee",
    paths.app + "coffee/modules/*.coffee",
    paths.app + "coffee/modules/common/*.coffee",
    paths.app + "coffee/modules/backlog/*.coffee",
    paths.app + "coffee/modules/taskboard/*.coffee",
    paths.app + "coffee/modules/kanban/*.coffee",
    paths.app + "coffee/modules/epics/*.coffee",
    paths.app + "coffee/modules/issues/*.coffee",
    paths.app + "coffee/modules/userstories/*.coffee",
    paths.app + "coffee/modules/tasks/*.coffee",
    paths.app + "coffee/modules/team/*.coffee",
    paths.app + "coffee/modules/wiki/*.coffee",
    paths.app + "coffee/modules/admin/*.coffee",
    paths.app + "coffee/modules/projects/*.coffee",
    paths.app + "coffee/modules/locales/*.coffee",
    paths.app + "coffee/modules/profile/*.js",
    paths.app + "coffee/modules/base/*.coffee",
    paths.app + "coffee/modules/resources/*.coffee",
    paths.app + "coffee/modules/user-settings/*.coffee",
    paths.app + "coffee/modules/integrations/*.coffee",
    paths.app + "modules/**/*.module.coffee",
    paths.app + "modules/**/*.coffee"
];

paths.libs = [
    paths.modules + "bluebird/js/browser/bluebird.js",
    paths.modules + "jquery/dist/jquery.js",
    paths.modules + "lodash/lodash.js",
    paths.modules + "messageformat/messageformat.js",
    paths.modules + "angular/angular.js",
    paths.modules + "angular-route/angular-route.js",
    paths.modules + "angular-sanitize/angular-sanitize.js",
    paths.modules + "angular-animate/angular-animate.js",
    paths.modules + "angular-aria/angular-aria.js",
    paths.modules + "angular-translate/dist/angular-translate.js",
    paths.modules + "angular-translate-loader-partial/angular-translate-loader-partial.js",
    paths.modules + "angular-translate-loader-static-files/angular-translate-loader-static-files.js",
    paths.modules + "angular-translate-interpolation-messageformat/angular-translate-interpolation-messageformat.js",
    paths.modules + "moment/moment.js",
    paths.modules + "checksley/checksley.js",
    paths.modules + "pikaday/pikaday.js",
    paths.modules + "Flot/jquery.flot.js",
    paths.modules + "Flot/jquery.flot.pie.js",
    paths.modules + "Flot/jquery.flot.time.js",
    paths.modules + "flot-axislabels/jquery.flot.axislabels.js",
    paths.modules + "jquery.flot.tooltip/js/jquery.flot.tooltip.js",
    paths.modules + "raven-js/dist/raven.js",
    paths.modules + "l.js/l.js",
    paths.modules + "ng-infinite-scroll/build/ng-infinite-scroll.js",
    paths.modules + "immutable/dist/immutable.js",
    paths.modules + "intro.js/intro.js",
    paths.modules + "dragula/dist/dragula.js",
    paths.modules + "awesomplete/awesomplete.js",
    paths.modules + "medium-editor/dist/js/medium-editor.js",
    paths.modules + "to-markdown/dist/to-markdown.js",
    paths.modules + "markdown-it/dist/markdown-it.js",
    paths.modules + "prismjs/prism.js",
    paths.modules + "prismjs/plugins/custom-class/prism-custom-class.js",
    paths.modules + "medium-editor-autolist/dist/autolist.js",
    paths.modules + "autolinker/dist/Autolinker.js",
    paths.app + "js/dom-autoscroller.js",
    paths.app + "js/dragula-drag-multiple.js",
    paths.app + "js/tg-repeat.js",
    paths.app + "js/sha1-custom.js",
    paths.app + "js/murmurhash3_gc.js",
    paths.app + "js/medium-mention.js",
    paths.app + "js/markdown-it-lazy-headers.js"
];

paths.libs.forEach(function(file) {
    try {
        // Query the entry
        stats = fs.lstatSync(file);
    }
    catch (e) {
        console.log(file);
    }
});

var isDeploy = argv["_"].indexOf("deploy") !== -1;

/*
############################################################################
# Layout/CSS Related tasks
##############################################################################
*/

var jadeIncludes = paths.app +'partials/includes/**/*';

gulp.task("jade", function() {
    return gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cached("jade"))
        .pipe(jade({pretty: true, locals:{v:version}}))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("jade-inheritance", function() {
    return gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cached("jade"))
        .pipe(jadeInheritance({basedir: "./app/"}))
        .pipe(jade({pretty: true, locals:{v: version}}))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("copy-index", function() {
    return gulp.src(paths.tmp + "index.html")
        .pipe(gulp.dest(paths.dist));
});

gulp.task("template-cache", function() {
    return gulp.src(paths.htmlPartials)
        .pipe(gulpif(isDeploy, replace(/e2e-([a-z\-]+)/g, '')))
        .pipe(templateCache({standalone: true}))
        .pipe(gulpif(isDeploy, uglify()))
        .pipe(gulp.dest(paths.distVersion + "js/"))
        .pipe(gulpif(!isDeploy, livereload()));
});

gulp.task("jade-deploy", function(cb) {
    return runSequence("jade", "copy-index", "template-cache", cb);
});

gulp.task("jade-watch", function(cb) {
    return runSequence("jade-inheritance", "copy-index", "template-cache", cb);
});

/*
##############################################################################
# CSS Related tasks
##############################################################################
*/

gulp.task("scss-lint", [], function() {
    var ignore = [
        "!" + paths.app + "/styles/shame/**/*.scss",
    ];

    var fail = process.argv.indexOf("--fail") !== -1;

    var sassFiles = paths.sass.concat(themes.current.customScss, ignore);

    return gulp.src(sassFiles)
        .pipe(gulpif(!isDeploy, cache(scsslint({endless: true, sync: true, config: ".scss-lint.yml"}), {
          success: function(scsslintFile) {
            return scsslintFile.scsslint.success;
          },
          value: function(scsslintFile) {
            return {
              scsslint: scsslintFile.scsslint
            };
          }
        })))
        .pipe(gulpif(fail, scsslint.failReporter()));
});

gulp.task("clear-sass-cache", function() {
    delete cached.caches["sass"];
});

gulp.task("sass-compile", [], function() {
    return gulp.src(paths.sass)
        .pipe(addsrc.append(themes.current.customScss))
        .pipe(plumber())
        .pipe(insert.prepend('@import "dependencies";'))
        .pipe(cached("sass"))
        .pipe(sass({
            includePaths: [
                paths.app + "styles/extras/",
                themes.current.path
            ]
        }))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("css-lint-app", function() {
    var cssFiles = paths.css.concat(themes.current.customCss);

    return gulp.src(cssFiles)
        .pipe(gulpif(!isDeploy, cache(csslint("csslintrc.json"), {
          success: function(csslintFile) {
              if (csslintFile.csslint) {
                  return csslintFile.csslint.success;
              } else {
                  return false;
              }
          },
          value: function(csslintFile) {
            return {
              csslint: csslintFile.csslint
            };
          }
        })))
        .pipe(csslint.reporter());
});

gulp.task("app-css", function() {
    return gulp.src(paths.css)
        .pipe(order(paths.css_order, {base: '.'}))
        .pipe(concat("theme-" + themes.current.name + ".css"))
        .pipe(autoprefixer({
            cascade: false
        }))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("vendor-css", function() {
    var isPrism = function(file) {
        return file.path.indexOf('prism-okaidia') !== -1;
    };

    return gulp.src(paths.css_vendor)
        .pipe(gulpif(isPrism, classPrefix('prism-')))
        .pipe(concat("vendor.css"))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("main-css", function() {
    var _paths = [
        paths.tmp + "vendor.css",
        paths.tmp + "theme-" + themes.current.name + ".css"
    ];

    return gulp.src(_paths)
        .pipe(concat("theme-" + themes.current.name + ".css"))
        .pipe(gulpif(isDeploy, minifyCSS({noAdvanced: true})))
        .pipe(gulp.dest(paths.distVersion + "styles/"))
        .pipe(livereload());
});

var compileThemes = function (cb) {
    return runSequence("clear",
                       "scss-lint",
                       "sass-compile",
                       "css-lint-app",
                       ["app-css", "vendor-css"],
                       "main-css",
                       function() {
                           themes.next();

                           if (themes.current) {
                               compileThemes(cb);
                           } else {
                               cb();
                           }
                       });
};

gulp.task("compile-themes", function(cb) {
    compileThemes(cb);
});

gulp.task("styles", function(cb) {
    return runSequence("scss-lint",
                       "sass-compile",
                       ["app-css", "vendor-css"],
                       "main-css",
                       cb);
});

gulp.task("styles-lint", function(cb) {
    return runSequence("scss-lint",
                       "sass-compile",
                       "css-lint-app",
                       ["app-css", "vendor-css"],
                       "main-css",
                       cb);
});

gulp.task("styles-dependencies", function(cb) {
    return runSequence("clear-sass-cache",
                       "sass-compile",
                       ["app-css", "vendor-css"],
                       "main-css",
                       cb);
});

/*
##############################################################################
# JS Related tasks
##############################################################################
*/

gulp.task("prism-languages", function(cb) {
    var files = fs.readdirSync(paths.modules + "prismjs/components");

    files = files.filter(function(file) {
        return file.indexOf('.min.js') != -1;
    });

    files = files.map(function(file) {
        return {
            file: file,
            name: /prism-(.*)\.min\.js/g.exec(file)[1]
        };
    });

    var filesStr = JSON.stringify(files);

    fs.writeFileSync(__dirname + '/prism-languages.json', filesStr, {
        flag: 'w+'
    });

    cb();
});

gulp.task("emoji", function(cb) {
    // don't add to package.json
    var Jimp = require("jimp");

    //var emojiFolder = "";
    var emojiPath = "../emoji-data/";

    var emojis = require(emojiPath + "emoji.json");

    emojis = emojis.filter(function(emoji) {
        return emoji.has_img_twitter;
    });

    emojis = emojis.map(function(emoji) {
        return {
            name: emoji.short_name,
            image: emoji.image,
            id: emoji.unified.toLowerCase()
        };
    });

    emojis = emojis.sort(function(a, b) {
        if(a.name < b.name) return -1;
        if(a.name > b.name) return 1;
        return 0;
    });

    emojis.forEach(function(emoji) {
        Jimp.read(emojiPath + "img-twitter-64/" + emoji.image, function (err, lenna) {
            if (err) throw err;

            lenna
                .resize(16, 16)
                .quality(100)
                .write(__dirname + '/emojis/' + emoji.image);
        });
    });

    var emojisStr = JSON.stringify(emojis);
    fs.writeFileSync(__dirname + '/emojis/emojis-data.json', emojisStr, {
        flag: 'w+'
    });

    cb();
});

gulp.task("conf", function() {
    return gulp.src(["conf/conf.example.json"])
        .pipe(gulp.dest(paths.dist));
});

gulp.task("app-loader", function() {
    return gulp.src("app-loader/app-loader.coffee")
        .pipe(replace("___VERSION___", version))
        .pipe(coffee())
        .pipe(gulpif(isDeploy, uglify()))
        .pipe(gulp.dest(paths.distVersion + "js/"));
});

gulp.task("locales", function() {
    var plugins = gulp.src(paths.app + "modules/**/locales/*.json")
        .pipe(rename(function (localeFile) {
            // rename app/modules/compiles-modules/tg-contrib/locales/locale-en.json
            // to tg-contrib/locale-en.json

            var pluginPath = path.join(localeFile.dirname, '..');
            var pluginFolder = pluginPath.split('/').pop();

            localeFile.dirname = pluginFolder;
        }));

    var core = gulp.src(paths.locales);

    return mergeStream(plugins, core)
            .pipe(gulpif(isDeploy, jsonminify()))
            .pipe(gulp.dest(paths.distVersion + "locales"));
});

gulp.task("coffee-lint", function () {
    gulp.src([
        paths.app + "modules/**/*.coffee",
        "!" + paths.app + "modules/**/*.spec.coffee"
    ])
        .pipe(gulpif(!isDeploy, cache(coffeelint(), {
            key: function(lintFile) {
                return "coffee-lint" + lintFile.contents.toString('utf8');
            },
            success: function(lintFile) {
                return lintFile.coffeelint.success;
            },
            value: function(lintFile) {
                return {
                    coffeelint: lintFile.coffeelint
                };
            }
        })))
        .pipe(coffeelint.reporter());
});

gulp.task("coffee", function() {
    var filter = gulpFilter(['*', '!*.map']);

    return gulp.src(paths.coffee)
        .pipe(order(paths.coffee_order, {base: '.'}))
        .pipe(sourcemaps.init())
        .pipe(cache(coffee()))
        .on("error", function(err) {
            console.log(err.toString());
            this.emit("end");
        })
        .pipe(concat("app.js"))
        .pipe(sourcemaps.write('./maps'))
        .pipe(gulp.dest(paths.distVersion + "js/"))
        .pipe(filter)
        .pipe(livereload());
});

gulp.task("moment-locales", function() {
    return gulp.src(paths.modules + "moment/locale/*")
        .pipe(gulpif(isDeploy, uglify()))
        .pipe(gulp.dest(paths.distVersion + "locales/moment-locales/"));
});

gulp.task("jslibs-watch", function() {
    return gulp.src(paths.libs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(gulp.dest(paths.distVersion + "js/"));
});

gulp.task("jslibs-deploy", function() {
    return gulp.src(paths.libs)
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(concat("libs.js"))
        .pipe(uglify())
        .pipe(sourcemaps.write("./maps"))
        .pipe(gulp.dest(paths.distVersion + "js/"));
});

gulp.task("app-watch", ["coffee", "conf", "locales", "moment-locales", "app-loader"]);

gulp.task("app-deploy", ["coffee", "conf", "locales", "moment-locales", "app-loader"], function() {
    return gulp.src(paths.distVersion + "js/app.js")
        .pipe(sourcemaps.init())
            .pipe(uglify())
        .pipe(sourcemaps.write("./maps"))
        .pipe(gulp.dest(paths.distVersion + "js/"));
});

/*
##############################################################################
# Common tasks
##############################################################################
*/
gulp.task("clear", ["clear-sass-cache"], function(done) {
  return cache.clearAll(done);
});

//SVG
gulp.task("copy-svg", function() {
    return gulp.src(paths.app + "/svg/**/*")
        .pipe(gulp.dest(paths.distVersion + "/svg/"));
});

gulp.task("copy-theme-svg", function() {
    return gulp.src(themes.current.path + "/svg/**/*")
        .pipe(gulp.dest(paths.distVersion + "/svg/" + themes.current.name));
});

gulp.task("copy-fonts", function() {
    return gulp.src(paths.app + "/fonts/*")
        .pipe(gulp.dest(paths.distVersion + "/fonts/"));
});

gulp.task("copy-theme-fonts", function() {
    return gulp.src(themes.current.path + "/fonts/*")
        .pipe(gulp.dest(paths.distVersion + "/fonts/" + themes.current.name));
});

gulp.task("copy-images", function() {
    return gulp.src([paths.app + "/images/**/*", paths.app + '/modules/compile-modules/**/images/*'])
        .pipe(gulpif(isDeploy, imagemin({progressive: true})))
        .pipe(gulp.dest(paths.distVersion + "/images/"));
});

gulp.task("copy-emojis", function() {
    return gulp.src([__dirname + "/emojis/*"])
        .pipe(gulp.dest(paths.distVersion + "/emojis/"));
});

gulp.task("copy-prism", ["prism-languages"], function() {
    var prismLanguages = require(__dirname + '/prism-languages.json');

    prismLanguages = prismLanguages.map(function(it) {
        return paths.modules + "prismjs/components/" + it.file;
    });

    return gulp.src(prismLanguages.concat(__dirname + '/prism-languages.json'))
        .pipe(gulp.dest(paths.distVersion + "/prism/"));
});

gulp.task("copy-theme-images", function() {
    return gulp.src(themes.current.path + "/images/**/*")
        .pipe(gulpif(isDeploy, imagemin({progressive: true})))
        .pipe(gulp.dest(paths.distVersion + "/images/"  + themes.current.name));
});

gulp.task("copy-extras", function() {
    return gulp.src(paths.extras + "/*")
        .pipe(gulp.dest(paths.dist + "/"));
});

gulp.task("link-images", ["copy-images"], function(cb) {
    try {
        fs.unlinkSync(paths.dist+"images");
    } catch (exception) {
    }
    fs.symlinkSync("./"+version+"/images", paths.dist+"images");
    cb();
});

gulp.task("copy", [
    "copy-fonts",
    "copy-theme-fonts",
    "copy-images",
    "copy-emojis",
    "copy-prism",
    "copy-theme-images",
    "copy-svg",
    "copy-theme-svg",
    "copy-extras"
]);

gulp.task("delete-old-version", function() {
    del.sync(paths.dist + "v-*");
});

gulp.task("delete-tmp", function() {
    del.sync(paths.tmp);
});

gulp.task("unused-css", ["default"], function() {
    return gulp.src([
        paths.distVersion + "js/app.js",
        paths.tmp + "**/*.html"
    ])
        .pipe(utils.unusedCss({
            css: paths.distVersion + "styles/theme-taiga.css"
        }));
});

gulp.task("express", function() {
    var express = require("express");
    var compression = require('compression');

    var app = express();

    app.use(compression()); //gzip

    app.use("/" + version + "/js", express.static(__dirname + "/dist/" + version + "/js"));
    app.use("/" + version + "/styles", express.static(__dirname + "/dist/" + version + "/styles"));
    app.use("/" + version + "/images", express.static(__dirname + "/dist/" + version + "/images"));
    app.use("/" + version + "/emojis", express.static(__dirname + "/dist/" + version + "/emojis"));
    app.use("/" + version + "/svg", express.static(__dirname + "/dist/" + version + "/svg"));
    app.use("/" + version + "/partials", express.static(__dirname + "/dist/" + version + "/partials"));
    app.use("/" + version + "/fonts", express.static(__dirname + "/dist/" + version + "/fonts"));
    app.use("/" + version + "/locales", express.static(__dirname + "/dist/" + version + "/locales"));
    app.use("/" + version + "/maps", express.static(__dirname + "/dist/" + version + "/maps"));
    app.use("/" + version + "/prism", express.static(__dirname + "/dist/" + version + "/prism"));
    app.use("/plugins", express.static(__dirname + "/dist/plugins"));
    app.use("/conf.json", express.static(__dirname + "/dist/conf.json"));
    app.use(require('connect-livereload')({
        port: 35729
    }));

    app.all("/*", function(req, res, next) {
        //Just send the index.html for other files to support HTML5Mode
        res.sendFile("index.html", {root: __dirname + "/dist/"});
    });

    app.listen(9001);
});

//Rerun the task when a file changes
gulp.task("watch", function() {
    livereload.listen();

    gulp.watch(paths.jade, ["jade-watch"]);
    gulp.watch(paths.sass_watch, ["styles-lint"]);
    gulp.watch(paths.styles_dependencies, ["styles-dependencies"]);
    gulp.watch(paths.svg, ["copy-svg"]);
    gulp.watch(paths.coffee, ["app-watch"]);
    gulp.watch(paths.libs, ["jslibs-watch"]);
    gulp.watch([paths.locales, paths.modulesLocales], ["locales"]);
    gulp.watch(paths.images, ["copy-images"]);
    gulp.watch(paths.fonts, ["copy-fonts"]);
});

gulp.task("deploy", function(cb) {
    runSequence("clear", "delete-old-version", "delete-tmp", [
        "copy",
        "jade-deploy",
        "app-deploy",
        "jslibs-deploy",
        "link-images",
        "compile-themes"
    ], cb);
});
//The default task (called when you run gulp from cli)
gulp.task("default", function(cb) {
    runSequence("delete-old-version", "delete-tmp", [
        "copy",
        "styles",
        "app-watch",
        "jslibs-watch",
        "jade-deploy",
        "express",
        "watch"
    ], cb);
});
