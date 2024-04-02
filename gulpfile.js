/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var gulp = require("gulp"),
    fs = require('fs'),
    imagemin = require("gulp-imagemin"),
    jade = require("gulp-jade"),
    coffee = require("gulp-coffee"),
    concat = require("gulp-concat"),
    uglify = require("gulp-uglify"),
    plumber = require("gulp-plumber"),
    rename = require("gulp-rename"),
    gulpif = require("gulp-if"),
    replace = require("gulp-replace"),
    sass = require('gulp-sass')(require('node-sass'));
    minifyCSS = require("gulp-clean-css"),
    stylelint = require('gulp-stylelint');
    cache = require("gulp-cache"),
    cached = require("gulp-cached"),
    jadeInheritance = require("gulp-jade-inheritance"),
    sourcemaps = require("gulp-sourcemaps"),
    insert = require("gulp-insert"),
    autoprefixer = require("gulp-autoprefixer"),
    templateCache = require("gulp-angular-templatecache"),
    order = require("gulp-order"),
    os = require('os'),
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

const availableThemes = JSON.stringify(themes.availableThemes.map((theme) => {
    return theme.name;
}));

var version = "v-" + Date.now();

// userpilot config
var userpilotToken = process.env.USERPILOT_TOKEN || null;
var zendeskToken = process.env.ZENDESK_TOKEN || null;
var disableRobots = process.env.DISABLE_ROBOTS || false;

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
    paths.modules + "@highlightjs/cdn-assets/styles/dracula.min.css"
];
paths.locales = paths.app + "locales/**/*.json";
paths.modulesLocales = paths.app + "modules/**/locales/*.json";
paths.elements = `./elements.js`;

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
    paths.modules + "jquery/dist/jquery.js",
    paths.modules + "lodash/lodash.js",
    paths.modules + "messageformat/messageformat.js",
    paths.modules + "angular/angular.js",
    paths.modules + "angular-route/angular-route.js",
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
    paths.modules + "autolinker/dist/Autolinker.js",
    paths.modules + "dom-autoscroller/dist/dom-autoscroller.js",
    paths.app + "js/angular-sanitize.js",
    paths.app + "js/dragula-drag-multiple.js",
    paths.app + "js/boards.js",
    paths.app + "js/tg-repeat.js",
    paths.app + "js/sha1-custom.js",
    paths.app + "js/murmurhash3_gc.js"
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

gulp.task("clear-sass-cache", function(done) {
    delete cached.caches["sass"];
    done();
});

gulp.task("clear", gulp.series("clear-sass-cache", function(done) {
    cache.clearAll();
    done();
}));

/*
############################################################################
# Layout/CSS Related tasks
##############################################################################
*/

gulp.task("jade", function() {
    return gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cached("jade"))
        .pipe(jade({
            pretty: true,
            locals:{
                v:version,
                userpilotToken: userpilotToken,
                disableRobots: disableRobots,
                zendeskToken: zendeskToken,
                availableThemes: availableThemes
            }
        }))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("jade-inheritance", function() {
    return gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cached("jade"))
        .pipe(jadeInheritance({basedir: "./app/"}))
        .pipe(jade({
            pretty: true,
            locals:{
                v: version,
                userpilotToken: userpilotToken,
                disableRobots: disableRobots,
                zendeskToken: zendeskToken,
                availableThemes: availableThemes
            }
        }))
        .pipe(gulp.dest(paths.tmp));
});

gulp.task("copy-index", function() {
    return gulp.src(paths.tmp + "index.html")
        .pipe(gulp.dest(paths.dist));
});

gulp.task("template-cache", function() {
    return gulp.src(paths.htmlPartials)
        .pipe(gulpif(isDeploy, replace(/e2e-([a-z\-]+)/g, '')))
        .pipe(templateCache({
            standalone: true,
            transformUrl: function(url) {
                if (url.startsWith('/')) {
                    return url.slice(1);
                }

                return url;
            }
        }))
        .pipe(gulpif(isDeploy, uglify()))
        .pipe(gulp.dest(paths.distVersion + "js/"))
        .pipe(gulpif(!isDeploy, livereload()));
});

gulp.task("jade-deploy", gulp.series("jade", "copy-index", "template-cache"));

gulp.task("jade-watch", gulp.series("jade-inheritance", "copy-index", "template-cache"));

/*
##############################################################################
# CSS Related tasks
##############################################################################
*/

gulp.task("scss-lint", function(done) {
    var ignore = [
        "!" + paths.app + "/styles/shame/**/*.scss",
    ];

    var fail = process.argv.indexOf("--fail") !== -1;

    var sassFiles = paths.sass.concat(themes.current.customScss, ignore);

    const task = gulp.src(sassFiles)
        .pipe(
            stylelint({
                failAfterError: fail,
                reporters: [
                    {formatter: 'string', console: true}
                ]
            },
            done,
        ));

    if (fail) {
        return task;
    } else {
        done();
    }
});

gulp.task("sass-compile", function() {
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
        .pipe(gulpif(isDeploy, minifyCSS({})))
        .pipe(gulp.dest(paths.distVersion + "styles/"))
        .pipe(livereload());
});

gulp.task("compile-theme", gulp.series(
    "clear",
    "scss-lint",
    "sass-compile",
    gulp.parallel("app-css", "vendor-css"),
    "main-css",
    function(done) {
        themes.next();
        done();
    }));

gulp.task("compile-themes", gulp.series(new Array(themes.size).fill('compile-theme')));

gulp.task("styles", gulp.series(
    gulp.parallel("scss-lint", "sass-compile"),
    gulp.parallel("app-css", "vendor-css"),
    "main-css"
));

gulp.task("styles-lint", gulp.series(
    gulp.parallel("scss-lint", "sass-compile"),
    gulp.parallel("app-css", "vendor-css"),
    "main-css"
));

gulp.task("styles-dependencies", gulp.series(
    "clear-sass-cache",
    "sass-compile",
    gulp.parallel("app-css", "vendor-css"),
    "main-css")
);

/*
##############################################################################
# JS Related tasks
##############################################################################
*/

gulp.task("emoji", function(cb) {
    // don't add to package.json
    var Jimp = require("jimp");

    //var emojiFolder = "";
    var emojiPath = "../emoji-data/";

    var emojis = require(emojiPath + "emoji.json");

    emojis = emojis.filter(function(emoji) {
        return emoji.has_img_twitter;
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

    emojis = emojis.map(function(emoji) {
        return emoji.short_names.map(function(name) {
            return {
                name: name,
                image: emoji.image,
                id: emoji.unified.toLowerCase()
            };
        });
    }).reduce(function(x, y) { return x.concat(y) }, []);

    emojis = emojis.sort(function(a, b) {
        if(a.name < b.name) return -1;
        if(a.name > b.name) return 1;
        return 0;
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
    replace_lang_path = { "zh-cn": "zh-hans",
            "zh-tw": "zh-hant" }

    return gulp.src(paths.modules + "moment/locale/*")
        .pipe(gulpif(isDeploy, uglify()))
        .pipe(rename(function (path) {
            if (path.basename in replace_lang_path) {
                path.basename = replace_lang_path[path.basename]
            }
        }))
        .pipe(gulp.dest(paths.distVersion + "locales/moment-locales/"));
});

gulp.task("jslibs-watch", function() {
    return gulp.src([...paths.libs, paths.modules + "@highlightjs/cdn-assets/highlight.min.js"])
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
        //  we can't uglify highlightjs
        .pipe(gulp.src([paths.modules + "@highlightjs/cdn-assets/highlight.min.js"]))
        .pipe(concat("libs.js"))
        .pipe(sourcemaps.write("./maps"))
        .pipe(gulp.dest(paths.distVersion + "js/"));
});

gulp.task("elements", function() {
    return gulp.src(paths.elements)
        .pipe(uglify())
        .pipe(gulp.dest(paths.distVersion + "js/"));
});

gulp.task("app-watch", gulp.series("coffee", "conf", "locales", "moment-locales", "app-loader"));

gulp.task("app-deploy", gulp.series("coffee", "conf", "locales", "moment-locales", "app-loader", function() {
    return gulp.src(paths.distVersion + "js/app.js")
        .pipe(sourcemaps.init())
            .pipe(uglify())
        .pipe(sourcemaps.write("./maps"))
        .pipe(gulp.dest(paths.distVersion + "js/"));
}));

/*
##############################################################################
# Common tasks
##############################################################################
*/

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

gulp.task("copy-theme-images", function() {
    return gulp.src(themes.current.path + "/images/**/*")
        .pipe(gulpif(isDeploy, imagemin({progressive: true})))
        .pipe(gulp.dest(paths.distVersion + "/images/"  + themes.current.name));
});

gulp.task("copy-extras", function() {
    return gulp.src(paths.extras + "/*")
        .pipe(gulp.dest(paths.dist + "/"));
});

gulp.task("copy-ckeditor-translations", function() {
    return gulp.src(paths.modules + "taiga-html-editor/packages/ckeditor5-build-classic/build/translations/*")
        .pipe(gulp.dest(paths.distVersion + "/ckeditor-translations/"));
});

gulp.task("copy-hljs-languages", function() {
    return gulp.src(paths.modules + "@highlightjs/cdn-assets/languages/*")
        .pipe(gulp.dest(paths.distVersion + "/highlightjs-languages/"));
});

gulp.task("link-images", gulp.series("copy-images", function(cb) {
    try {
        fs.unlinkSync(paths.dist+"images");
    } catch (exception) {
    }
    fs.symlinkSync("./"+version+"/images", paths.dist+"images");
    cb();
}));

gulp.task("copy", gulp.parallel([
    "copy-fonts",
    "copy-theme-fonts",
    "copy-images",
    "copy-emojis",
    "copy-theme-images",
    "copy-svg",
    "copy-theme-svg",
    "copy-extras",
    "copy-ckeditor-translations",
    "copy-hljs-languages"
]));

gulp.task("delete-old-version", function() {
    return del(paths.dist + "v-*");
});

gulp.task("delete-tmp", function() {
    return del(paths.tmp);
});

gulp.task("express", function(cb) {
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
    app.use("/" + version + "/ckeditor-translations", express.static(__dirname + "/dist/" + version + "/ckeditor-translations"));
    app.use("/" + version + "/highlightjs-languages", express.static(__dirname + "/dist/" + version + "/highlightjs-languages"));
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
    cb();
});

//Rerun the task when a file changes
gulp.task("watch", function(cb) {
    livereload.listen();

    gulp.watch(paths.jade, gulp.parallel(["jade-watch"]));
    gulp.watch(paths.sass_watch, gulp.parallel(["styles-lint"]));
    gulp.watch(paths.styles_dependencies, gulp.parallel(["styles-dependencies"]));    gulp.watch(paths.svg, gulp.parallel(["copy-svg"]));
    gulp.watch(paths.coffee, gulp.parallel(["app-watch"]));
    gulp.watch(paths.libs, gulp.parallel(["jslibs-watch"]));
    gulp.watch(paths.elements, gulp.parallel(["elements"]));
    gulp.watch([paths.locales, paths.modulesLocales], gulp.parallel(["locales"]));
    gulp.watch(paths.images, gulp.parallel(["copy-images"]));

    cb();
});

gulp.task("deploy", gulp.series(
    "clear",
    "delete-old-version",
    "delete-tmp",
    gulp.parallel(
        "copy",
        "jade-deploy",
        "app-deploy",
        "jslibs-deploy",
        "elements",
        "link-images",
        "compile-themes"
    )
));

//The default task (called when you run gulp from cli)
gulp.task("default", gulp.series(
    "delete-old-version",
    "delete-tmp",
    gulp.parallel(
        "copy",
        "styles",
        "app-watch",
        "jslibs-watch",
        "jade-deploy",
        "elements",
        "express",
        "watch"
    ))
);

gulp.task("unused-css", gulp.series("default", function() {
    return gulp.src([
        paths.distVersion + "js/app.js",
        paths.tmp + "**/*.html"
    ])
    .pipe(utils.unusedCss({
        css: paths.distVersion + "styles/theme-taiga.css"
    }));
}));
