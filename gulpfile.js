var gulp = require("gulp"),
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
    coffeelint = require('gulp-coffeelint');

var argv = require('minimist')(process.argv.slice(2));

var utils = require("./gulp-utils");

var themes = utils.themes.sequence();

if (argv.theme) {
    themes.set(argv.theme);
}

var paths = {};
paths.app = "app/";
paths.dist = "dist/";
paths.tmp = "tmp/";
paths.extras = "extras/";
paths.vendor = "vendor/";

paths.jade = [
    paths.app + "**/*.jade"
];

paths.htmlPartials = [
    paths.tmp + "partials/**/*.html",
    paths.tmp + "plugins/**/*.html",
    paths.tmp + "modules/**/*.html",
    "!" + paths.tmp + "partials/includes/**/*.html",
    "!" + paths.tmp + "/modules/**/includes/**/*.html"
];

paths.images = paths.app + "images/**/*";
paths.svg = paths.app + "svg/**/*";
paths.css_vendor = paths.app + "styles/vendor/*.css";
paths.locales = paths.app + "locales/**/*.json";

paths.sass = [
    paths.app + "**/*.scss",
    "!" + paths.app + "/styles/bourbon/**/*.scss",
    "!" + paths.app + "/styles/dependencies/**/*.scss",
    "!" + paths.app + "/styles/extras/**/*.scss",
    "!" + paths.app + "/themes/**/variables.scss",
];

paths.sass_watch = paths.sass.concat(themes.current.customScss);

paths.styles_dependencies = [
    paths.app + "/styles/dependencies/**/*.scss",
    themes.current.customVariables
];

paths.css = [
    paths.tmp + "styles/**/*.css",
    paths.tmp + "modules/**/*.css",
    paths.tmp + "plugins/**/*.css"
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
    paths.tmp + "plugins/**/*.css",
    paths.tmp + "themes/**/*.css"
];

paths.coffee = [
    paths.app + "**/*.coffee",
    "!" + paths.app + "**/*.spec.coffee",
];

paths.coffee_order = [
    paths.app + "coffee/app.coffee",
    paths.app + "coffee/*.coffee",
    paths.app + "coffee/modules/controllerMixins.coffee",
    paths.app + "coffee/modules/*.coffee",
    paths.app + "coffee/modules/common/*.coffee",
    paths.app + "coffee/modules/backlog/*.coffee",
    paths.app + "coffee/modules/taskboard/*.coffee",
    paths.app + "coffee/modules/kanban/*.coffee",
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
    paths.app + "modules/**/*.coffee",
    paths.app + "plugins/*.coffee",
    paths.app + "plugins/**/*.coffee"
];

paths.libs = [
    paths.vendor + "bluebird/js/browser/bluebird.js",
    paths.vendor + "jquery/dist/jquery.js",
    paths.vendor + "lodash/dist/lodash.js",
    paths.vendor + "emoticons/lib/emoticons.js",
    paths.vendor + "underscore.string/lib/underscore.string.js",
    paths.vendor + "messageformat/messageformat.js",
    paths.vendor + "angular/angular.js",
    paths.vendor + "angular-route/angular-route.js",
    paths.vendor + "angular-sanitize/angular-sanitize.js",
    paths.vendor + "angular-animate/angular-animate.js",
    paths.vendor + "angular-translate/angular-translate.js",
    paths.vendor + "angular-translate-loader-static-files/angular-translate-loader-static-files.js",
    paths.vendor + "angular-translate-interpolation-messageformat/angular-translate-interpolation-messageformat.js",
    paths.vendor + "moment/min/moment-with-locales.js",
    paths.vendor + "checksley/checksley.js",
    paths.vendor + "pikaday/pikaday.js",
    paths.vendor + "jquery-flot/jquery.flot.js",
    paths.vendor + "jquery-flot/jquery.flot.pie.js",
    paths.vendor + "jquery-flot/jquery.flot.time.js",
    paths.vendor + "flot-axislabels/jquery.flot.axislabels.js",
    paths.vendor + "flot.tooltip/js/jquery.flot.tooltip.js",
    paths.vendor + "jquery-textcomplete/jquery.textcomplete.js",
    paths.vendor + "markitup-1x/markitup/jquery.markitup.js",
    paths.vendor + "malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.concat.min.js",
    paths.vendor + "raven-js/dist/raven.js",
    paths.vendor + "l.js/l.js",
    paths.vendor + "messageformat/locale/*.js",
    paths.vendor + "ngInfiniteScroll/build/ng-infinite-scroll.js",
    paths.vendor + "eventemitter2/lib/eventemitter2.js",
    paths.vendor + "immutable/dist/immutable.js",
    paths.app + "js/jquery.ui.git-custom.js",
    paths.app + "js/jquery-ui.drag-multiple-custom.js",
    paths.app + "js/jquery.ui.touch-punch.min.js",
    paths.app + "js/tg-repeat.js",
    paths.app + "js/sha1-custom.js"
];

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
        .pipe(jade({pretty: true, locals:{v:(new Date()).getTime()}}))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("jade-inheritance", function() {
    return gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cached("jade"))
        .pipe(jadeInheritance({basedir: "./app/"}))
        .pipe(jade({pretty: true, locals:{v:(new Date()).getTime()}}))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("copy-index", function() {
    return gulp.src(paths.tmp + "index.html")
        .pipe(gulp.dest(paths.dist));
});

gulp.task("template-cache", function() {
    return gulp.src(paths.htmlPartials)
        .pipe(templateCache({standalone: true}))
        .pipe(gulp.dest(paths.dist + "js/"));
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
        "!" + paths.app + "/styles/components/markitup.scss"
    ];

    var fail = process.argv.indexOf("--fail") !== -1;

    var sassFiles = paths.sass.concat(themes.current.customScss, ignore);

    return gulp.src(sassFiles)
        .pipe(gulpif(!isDeploy, cache(scsslint({endless: true, sync: true, config: "scsslint.yml"}), {
          success: function(scsslintFile) {
            return scsslintFile.scsslint.success;
          },
          value: function(scsslintFile) {
            return {
              scsslint: scsslintFile.scsslint
            };
          }
        })))
        .pipe(gulpif(fail, scsslint.failReporter()))
});

gulp.task("clear-sass-cache", function() {
    delete cached.caches["sass"];
});

gulp.task("sass-compile", [], function() {
    var sassFiles = paths.sass.concat(themes.current.customScss);

    return gulp.src(sassFiles)
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
            return csslintFile.csslint.success;
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
    var cssFiles = paths.css.concat(themes.current.customCss);

    return gulp.src(cssFiles)
        .pipe(order(paths.css_order, {base: '.'}))
        .pipe(concat("theme-" + themes.current.name + ".css"))
        .pipe(autoprefixer({
            cascade: false
        }))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("vendor-css", function() {
    return gulp.src(paths.css_vendor)
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
        .pipe(gulp.dest(paths.dist + "styles/"))
});

var compileThemes = function (cb) {
    return runSequence("clear",
                       "scss-lint",
                       "sass-compile",
                       "css-lint-app",
                       ["app-css", "vendor-css"],
                       "main-css",
                       function() {
                           themes.next()

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
gulp.task("conf", function() {
    return gulp.src(["conf/conf.example.json"])
        .pipe(gulp.dest(paths.dist + "js/"));
});

gulp.task("app-loader", function() {
    return gulp.src("app-loader/app-loader.coffee")
        .pipe(replace("___VERSION___", (new Date()).getTime()))
        .pipe(coffee())
        .pipe(gulp.dest(paths.dist + "js/"));
});

gulp.task("locales", function() {
    return gulp.src(paths.locales)
        .pipe(gulp.dest(paths.dist + "locales"));
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
        .pipe(gulp.dest(paths.dist + "js/"));
});

gulp.task("jslibs-watch", function() {
    return gulp.src(paths.libs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(gulp.dest(paths.dist + "js/"));
});

gulp.task("jslibs-deploy", function() {
    return gulp.src(paths.libs)
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(concat("libs.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(sourcemaps.write("./maps"))
        .pipe(gulp.dest(paths.dist + "js/"));
});

gulp.task("app-watch", ["coffee-lint", "coffee", "conf", "locales", "app-loader"]);

gulp.task("app-deploy", ["coffee", "conf", "locales", "app-loader"], function() {
    return gulp.src(paths.dist)
        .pipe(order(paths.coffee_order, {base: '.'}))
        .pipe(sourcemaps.init())
            .pipe(concat("app.js"))
            .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(sourcemaps.write("./maps"))
        .pipe(gulp.dest(paths.dist + "js/"));
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
        .pipe(gulp.dest(paths.dist + "/svg/"));
});

gulp.task("copy-theme-svg", function() {
    return gulp.src(themes.current.path + "/svg/**/*")
        .pipe(gulp.dest(paths.dist + "/svg/" + themes.current.name));
});

gulp.task("copy-fonts", function() {
    return gulp.src(paths.app + "/fonts/*")
        .pipe(gulp.dest(paths.dist + "/fonts/"));
});

gulp.task("copy-theme-fonts", function() {
    return gulp.src(themes.current.path + "/fonts/*")
        .pipe(gulp.dest(paths.dist + "/fonts/" + themes.current.name));
});

gulp.task("copy-images", function() {
    return gulp.src(paths.app + "/images/**/*")
        .pipe(gulpif(isDeploy, imagemin({progressive: true})))
        .pipe(gulp.dest(paths.dist + "/images/"));
});

gulp.task("copy-theme-images", function() {
    return gulp.src(themes.current.path + "/images/**/*")
        .pipe(gulpif(isDeploy, imagemin({progressive: true})))
        .pipe(gulp.dest(paths.dist + "/images/"  + themes.current.name));
});

gulp.task("copy-images-plugins", function() {
    return gulp.src(paths.app + "/plugins/**/images/*")
        .pipe(flatten())
        .pipe(gulp.dest(paths.dist + "/images/"));
});

gulp.task("copy-plugin-templates", function() {
    return gulp.src(paths.app + "/plugins/**/templates/**/*.html")
        .pipe(gulp.dest(paths.dist + "/plugins/"));
});

gulp.task("copy-extras", function() {
    return gulp.src(paths.extras + "/*")
        .pipe(gulp.dest(paths.dist + "/"));
});

gulp.task("copy", [
    "copy-fonts",
    "copy-theme-fonts",
    "copy-images",
    "copy-theme-images",
    "copy-images-plugins",
    "copy-plugin-templates",
    "copy-svg",
    "copy-theme-svg",
    "copy-extras"
]);

gulp.task("delete-tmp", function() {
    del.sync(paths.tmp);
});

gulp.task("express", function() {
    var express = require("express");
    var app = express();

    app.use("/js", express.static(__dirname + "/dist/js"));
    app.use("/styles", express.static(__dirname + "/dist/styles"));
    app.use("/images", express.static(__dirname + "/dist/images"));
    app.use("/svg", express.static(__dirname + "/dist/svg"));
    app.use("/partials", express.static(__dirname + "/dist/partials"));
    app.use("/fonts", express.static(__dirname + "/dist/fonts"));
    app.use("/plugins", express.static(__dirname + "/dist/plugins"));
    app.use("/locales", express.static(__dirname + "/dist/locales"));
    app.use("/maps", express.static(__dirname + "/dist/maps"));

    app.all("/*", function(req, res, next) {
        //Just send the index.html for other files to support HTML5Mode
        res.sendFile("index.html", {root: __dirname + "/dist/"});
    });

    app.listen(9001);
});

//Rerun the task when a file changes
gulp.task("watch", function() {
    gulp.watch(paths.jade, ["jade-watch"]);
    gulp.watch(paths.sass_watch, ["styles"]);
    gulp.watch(paths.styles_dependencies, ["styles-dependencies"]);
    gulp.watch(paths.svg, ["copy-svg"]);
    gulp.watch(paths.coffee, ["app-watch"]);
    gulp.watch(paths.libs, ["jslibs-watch"]);
    gulp.watch(paths.locales, ["locales"]);
    gulp.watch(paths.images, ["copy-images"]);
    gulp.watch(paths.fonts, ["copy-fonts"]);
});

gulp.task("deploy", function(cb) {
    runSequence("clear", "delete-tmp", [
        "copy",
        "jade-deploy",
        "app-deploy",
        "jslibs-deploy",
        "compile-themes"
    ], cb);
});
//The default task (called when you run gulp from cli)
gulp.task("default", function(cb) {
    runSequence("delete-tmp", [
        "copy",
        "styles",
        "app-watch",
        "jslibs-watch",
        "jade-deploy",
        "express",
        "watch"
    ], cb);
});
