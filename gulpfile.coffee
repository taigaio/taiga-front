gulp = require("gulp")
jade = require("gulp-jade")
gutil = require("gulp-util")
coffee = require("gulp-coffee")
concat = require("gulp-concat")
uglify = require("gulp-uglify")
plumber = require("gulp-plumber")
wrap = require("gulp-wrap")
rename = require("gulp-rename")
flatten = require('gulp-flatten')
gulpif = require('gulp-if')

minifyHTML = require("gulp-minify-html")
sass = require("gulp-ruby-sass")
csslint = require("gulp-csslint")
minifyCSS = require("gulp-minify-css")
watch = require("gulp-watch")
notify = require("gulp-notify")
scsslint = require("gulp-scss-lint")
newer = require("gulp-newer")
cache = require("gulp-cached")
jadeInheritance = require('gulp-jade-inheritance')
sourcemaps = require('gulp-sourcemaps')
insert = require("gulp-insert")
runSequence = require('run-sequence')
lazypipe = require('lazypipe')
rimraf = require('rimraf')
imagemin = require('gulp-imagemin')
autoprefixer = require('gulp-autoprefixer')
fs = require('fs')

mainSass = require("./main-sass").files

paths = {}
paths.app = "app/"
paths.dist = "dist/"
paths.tmp = "tmp/"
paths.tmpStyles = paths.tmp + "styles/"
paths.tmpStylesExtras = "#{paths.tmpStyles}/taiga-front-extras/**/*.css"
paths.extras = "extras/"

paths.jade = [
    paths.app + "index.jade",
    paths.app + "partials/**/*.jade",
    paths.app + "plugins/**/*.jade"
]

paths.images = paths.app + "images/**/*"
paths.svg = paths.app + "svg/**/*"
paths.css = paths.app + "styles/vendor/*.css"
paths.locales = paths.app + "locales/**/*.json"
paths.sass = [
    "#{paths.app}/styles/**/*.scss"
    "#{paths.app}/plugins/**/*.scss"
    "!#{paths.app}/styles/bourbon/**/*.scss"
    "!#{paths.app}/styles/dependencies/**/*.scss"
    "!#{paths.app}/styles/extras/**/*.scss"
]

paths.coffee = [
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
    paths.app + "coffee/modules/base/*.coffee",
    paths.app + "coffee/modules/resources/*.coffee",
    paths.app + "coffee/modules/user-settings/*.coffee"
    paths.app + "coffee/modules/integrations/*.coffee"
    paths.app + "plugins/**/*.coffee"
]

paths.js = [
    paths.app + "vendor/jquery/dist/jquery.js",
    paths.app + "vendor/lodash/dist/lodash.js",
    paths.app + "vendor/emoticons/lib/emoticons.js",
    paths.app + "vendor/underscore.string/lib/underscore.string.js",
    paths.app + "vendor/angular/angular.js",
    paths.app + "vendor/angular-route/angular-route.js",
    paths.app + "vendor/angular-sanitize/angular-sanitize.js",
    paths.app + "vendor/angular-animate/angular-animate.js",
    paths.app + "vendor/i18next/i18next.js",
    paths.app + "vendor/moment/min/moment-with-langs.js",
    paths.app + "vendor/checksley/checksley.js",
    paths.app + "vendor/pikaday/pikaday.js",
    paths.app + "vendor/jquery-flot/jquery.flot.js",
    paths.app + "vendor/jquery-flot/jquery.flot.pie.js",
    paths.app + "vendor/jquery-flot/jquery.flot.time.js",
    paths.app + "vendor/jquery-flot/jquery.flot.time.js",
    paths.app + "vendor/flot-axislabels/jquery.flot.axislabels.js",
    paths.app + "vendor/jquery-textcomplete/jquery.textcomplete.js",
    paths.app + "vendor/markitup-1x/markitup/jquery.markitup.js",
    paths.app + "vendor/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.concat.min.js",
    paths.app + "vendor/raven-js/dist/raven.js",
    paths.app + "js/jquery.ui.git-custom.js",
    paths.app + "js/jquery-ui.drag-multiple-custom.js",
    paths.app + "js/sha1-custom.js",
    paths.app + "plugins/**/*.js"
]

isDeploy = process.argv[process.argv.length - 1] == 'deploy'

############################################################################
# Layout/CSS Related tasks
##############################################################################

gulp.task "jade-deploy", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cache("jade"))
        .pipe(jade({pretty: false}))
        .pipe(gulp.dest(paths.dist + "partials/"))

gulp.task "jade-watch", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cache("jade"))
        .pipe(jadeInheritance({basedir: "./app"}))
        .pipe(jade({pretty: true}))
        .pipe(gulp.dest(paths.dist))

gulp.task "templates", ->
    gulp.src(paths.app + "index.jade")
        .pipe(plumber())
        .pipe(jade({pretty: true, locals:{v:(new Date()).getTime()}}))
        .pipe(gulp.dest(paths.dist))

##############################################################################
# CSS Related tasks
##############################################################################

gulp.task "sass-lint", ->
    gulp.src(paths.sass)
        .pipe(cache("sasslint"))
        .pipe(gulpif(!isDeploy, scsslint({config: "scsslint.yml"})))

gulp.task "sass-compile", ["sass-lint"], ->
    gulp.src(paths.sass)
        .pipe(plumber())
        .pipe(cache("scss"))
        .pipe(insert.prepend('@import "dependencies";'))
        .pipe(sass({
            'sourcemap=none': true,
            loadPath: [
                "#{paths.app}styles/extras/"
            ]
        }))
        .pipe(gulp.dest(paths.tmpStyles))

csslintChannel = lazypipe()
    .pipe(csslint, "csslintrc.json")
    .pipe(csslint.reporter)

gulp.task "css-lint-app", ->
    gulp.src(mainSass.concat([paths.tmpStylesExtras]))
        .pipe(cache("csslint"))
        .pipe(gulpif(!isDeploy, csslintChannel()))

gulp.task "css-join", ["css-lint-app"], ->
    gulp.src(mainSass.concat([paths.tmpStylesExtras]))
        .pipe(concat("app.css"))
        .pipe(autoprefixer({
            cascade: false
        }))
        .pipe(gulp.dest(paths.tmp))

gulp.task "css-app", (cb) ->
    runSequence("sass-compile", "css-join", cb)

gulp.task "css-vendor", ->
    gulp.src(paths.css)
        .pipe(concat("vendor.css"))
        .pipe(gulp.dest(paths.tmp))

gulp.task "delete-tmp-styles", (cb) ->
    rimraf(paths.tmpStyles, cb)

gulp.task "styles-watch", ["css-app", "css-vendor"], ->
    _paths = [
        paths.tmp + "vendor.css",
        paths.tmp + "app.css"
    ]

    gulp.src(_paths)
        .pipe(concat("main.css"))
        .pipe(gulpif(isDeploy, minifyCSS({noAdvanced: true})))
        .pipe(gulp.dest(paths.dist + "styles/"))

gulp.task "styles", ["delete-tmp-styles"], ->
    gulp.start("styles-watch")

##############################################################################
# JS Related tasks
##############################################################################

gulp.task "conf", ->
    if !fs.existsSync(paths.dist + "js/conf.js")
        gulp.src("conf/conf.example.js")
            .pipe(rename("conf.js"))
            .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "locales", ->
    gulp.src("app/locales/en/app.json")
        .pipe(wrap("angular.module('taigaBase').value('localesEn', <%= contents %>);"))
        .pipe(rename("locales.en.js"))
        .pipe(gulp.dest(paths.tmp))

gulp.task "coffee", ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(coffee())
        .pipe(concat("app.js"))
        .pipe(gulp.dest(paths.tmp))

gulp.task "jslibs-watch", ->
    gulp.src(paths.js)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "jslibs-deploy", ->
    gulp.src(paths.js)
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(concat("libs.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "app-watch", ["coffee", "conf", "locales"], ->
    _paths = [
        paths.tmp + "app.js",
        paths.tmp + "locales.en.js"
    ]

    gulp.src(_paths)
        .pipe(concat("app.js"))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "app-deploy", ["coffee", "conf", "locales"], ->
    _paths = [
        paths.tmp + "app.js",
        paths.tmp + "locales.en.js"
    ]

    gulp.src(_paths)
        .pipe(sourcemaps.init())
            .pipe(concat("app.js"))
            .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest(paths.dist + "js/"))

##############################################################################
# Common tasks
##############################################################################

# SVG
gulp.task "copy-svg",  ->
    gulp.src("#{paths.app}/svg/**/*")
        .pipe(gulp.dest("#{paths.dist}/svg/"))

gulp.task "copy-fonts",  ->
    gulp.src("#{paths.app}/fonts/*")
        .pipe(gulp.dest("#{paths.dist}/fonts/"))

gulp.task "copy-images",  ->
    gulp.src("#{paths.app}/images/**/*")
        .pipe(imagemin({progressive: true}))
        .pipe(gulp.dest("#{paths.dist}/images/"))

    gulp.src("#{paths.app}/plugins/**/images/*")
        .pipe(flatten())
        .pipe(gulp.dest("#{paths.dist}/images/"))

gulp.task "copy-plugin-templates",  ->
    gulp.src("#{paths.app}/plugins/**/templates/**/*.html")
        .pipe(gulp.dest("#{paths.dist}/plugins/"))

gulp.task "copy-extras", ->
    gulp.src("#{paths.extras}/*")
        .pipe(gulp.dest("#{paths.dist}/"))


gulp.task "copy", ["copy-fonts", "copy-images", "copy-plugin-templates", "copy-svg", "copy-extras"]

gulp.task "express", ->
    express = require("express")
    app = express()

    app.use("/js", express.static("#{__dirname}/dist/js"))
    app.use("/styles", express.static("#{__dirname}/dist/styles"))
    app.use("/images", express.static("#{__dirname}/dist/images"))
    app.use("/svg", express.static("#{__dirname}/dist/svg"))
    app.use("/partials", express.static("#{__dirname}/dist/partials"))
    app.use("/fonts", express.static("#{__dirname}/dist/fonts"))
    app.use("/plugins", express.static("#{__dirname}/dist/plugins"))

    app.all "/*", (req, res, next) ->
        # Just send the index.html for other files to support HTML5Mode
        res.sendFile("index.html", {root: "#{__dirname}/dist/"})

    app.listen(9001)

# Rerun the task when a file changes
gulp.task "watch", ->
    gulp.watch(paths.jade, ["jade-watch"])
    gulp.watch(paths.app + "index.jade", ["templates"])
    gulp.watch(paths.sass, ["styles-watch"])
    gulp.watch(paths.svg, ["copy-svg"])
    gulp.watch(paths.coffee, ["app-watch"])
    gulp.watch(paths.js, ["jslibs-watch"])
    gulp.watch(paths.locales, ["app-watch"])
    gulp.watch(paths.images, ["copy-images"])
    gulp.watch(paths.fonts, ["copy-fonts"])


gulp.task "deploy", [
    "delete-tmp-styles",
    "templates",
    "copy",
    "jade-deploy",
    "app-deploy",
    "jslibs-deploy",
    "styles"
]

# The default task (called when you run gulp from cli)
gulp.task "default", [
    "delete-tmp-styles",
    "copy",
    "templates",
    "styles",
    "app-watch",
    "jslibs-watch",
    "jade-deploy",
    "express",
    "watch"
]
