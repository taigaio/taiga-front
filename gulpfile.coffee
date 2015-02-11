gulp = require("gulp")
jade = require("gulp-jade")
coffee = require("gulp-coffee")
concat = require("gulp-concat")
uglify = require("gulp-uglify")
plumber = require("gulp-plumber")
wrap = require("gulp-wrap")
rename = require("gulp-rename")
flatten = require("gulp-flatten")
gulpif = require("gulp-if")
replace = require("gulp-replace")
sass = require("gulp-ruby-sass")
csslint = require("gulp-csslint")
minifyCSS = require("gulp-minify-css")
scsslint = require("gulp-scss-lint")
cache = require("gulp-cached")
jadeInheritance = require("gulp-jade-inheritance")
sourcemaps = require("gulp-sourcemaps")
insert = require("gulp-insert")
imagemin = require("gulp-imagemin")
autoprefixer = require("gulp-autoprefixer")
templateCache = require("gulp-angular-templatecache")
changed = require("gulp-changed")

runSequence = require("run-sequence")
lazypipe = require("lazypipe")
del = require("del")

mainSass = require("./main-sass").files

paths = {}
paths.app = "app/"
paths.dist = "dist/"
paths.tmp = "tmp/"
paths.extras = "extras/"

paths.jade = [
    "#{paths.app}**/*.jade",
    "!#{paths.app}partial/includes/**",
]

paths.htmlPartials = [
    "#{paths.tmp}partials/**/*.html",
    "#{paths.tmp}plugins/**/*.html"
]

paths.images = "#{paths.app}images/**/*"
paths.svg = "#{paths.app}svg/**/*"
paths.css = "#{paths.app}styles/vendor/*.css"
paths.locales = "#{paths.app}locales/**/*.json"

paths.sass = [
    "#{paths.app}**/*.scss"
    "!#{paths.app}/styles/bourbon/**/*.scss"
    "!#{paths.app}/styles/dependencies/**/*.scss"
    "!#{paths.app}/styles/extras/**/*.scss"
]

paths.coffee = "#{paths.app}**/*.coffee"

paths.js = [
    "#{paths.tmp}coffee/app.js",
    "#{paths.tmp}coffee/*.js",
    "#{paths.tmp}coffee/modules/controllerMixins.js",
    "#{paths.tmp}coffee/modules/*.js",
    "#{paths.tmp}coffee/modules/common/*.js",
    "#{paths.tmp}coffee/modules/backlog/*.js",
    "#{paths.tmp}coffee/modules/taskboard/*.js",
    "#{paths.tmp}coffee/modules/kanban/*.js",
    "#{paths.tmp}coffee/modules/issues/*.js",
    "#{paths.tmp}coffee/modules/userstories/*.js",
    "#{paths.tmp}coffee/modules/tasks/*.js",
    "#{paths.tmp}coffee/modules/team/*.js",
    "#{paths.tmp}coffee/modules/wiki/*.js",
    "#{paths.tmp}coffee/modules/admin/*.js",
    "#{paths.tmp}coffee/modules/projects/*.js",
    "#{paths.tmp}coffee/modules/locales/*.js",
    "#{paths.tmp}coffee/modules/base/*.js",
    "#{paths.tmp}coffee/modules/resources/*.js",
    "#{paths.tmp}coffee/modules/user-settings/*.js",
    "#{paths.tmp}coffee/modules/integrations/*.js",
    "#{paths.tmp}plugins/**/*.js"
]

paths.libs = [
    "#{paths.app}vendor/jquery/dist/jquery.js",
    "#{paths.app}vendor/lodash/dist/lodash.js",
    "#{paths.app}vendor/emoticons/lib/emoticons.js",
    "#{paths.app}vendor/underscore.string/lib/underscore.string.js",
    "#{paths.app}vendor/angular/angular.js",
    "#{paths.app}vendor/angular-route/angular-route.js",
    "#{paths.app}vendor/angular-sanitize/angular-sanitize.js",
    "#{paths.app}vendor/angular-animate/angular-animate.js",
    "#{paths.app}vendor/i18next/i18next.js",
    "#{paths.app}vendor/moment/min/moment-with-langs.js",
    "#{paths.app}vendor/checksley/checksley.js",
    "#{paths.app}vendor/pikaday/pikaday.js",
    "#{paths.app}vendor/jquery-flot/jquery.flot.js",
    "#{paths.app}vendor/jquery-flot/jquery.flot.pie.js",
    "#{paths.app}vendor/jquery-flot/jquery.flot.time.js",
    "#{paths.app}vendor/flot-axislabels/jquery.flot.axislabels.js",
    "#{paths.app}vendor/flot.tooltip/js/jquery.flot.tooltip.js",
    "#{paths.app}vendor/jquery-textcomplete/jquery.textcomplete.js",
    "#{paths.app}vendor/markitup-1x/markitup/jquery.markitup.js",
    "#{paths.app}vendor/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.concat.min.js",
    "#{paths.app}vendor/raven-js/dist/raven.js",
    "#{paths.app}vendor/l.js/l.js",
    "#{paths.app}js/jquery.ui.git-custom.js",
    "#{paths.app}js/jquery-ui.drag-multiple-custom.js",
    "#{paths.app}js/sha1-custom.js",
]

isDeploy = process.argv[process.argv.length - 1] == "deploy"

############################################################################
# Layout/CSS Related tasks
##############################################################################

gulp.task "jade", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(changed(paths.tmp, {extension: ".html"}))
        .pipe(jade({pretty: true, locals:{v:(new Date()).getTime()}}))
        .pipe(gulp.dest(paths.tmp))

gulp.task "jade-inheritance", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(changed(paths.tmp, {extension: ".html"}))
        .pipe(jadeInheritance({basedir: "./app/"}))
        .pipe(jade({pretty: true, locals:{v:(new Date()).getTime()}}))
        .pipe(gulp.dest(paths.tmp))

gulp.task "copy-index", ->
    gulp.src(paths.tmp + "index.html")
        .pipe(gulp.dest(paths.dist))

gulp.task "template-cache", ->
    gulp.src(paths.htmlPartials)
        .pipe(templateCache({standalone: true}))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "jade-deploy", (cb) ->
    runSequence("jade", "copy-index", "template-cache", cb)

gulp.task "jade-watch", (cb) ->
    runSequence("jade-inheritance", "copy-index", "template-cache", cb)

##############################################################################
# CSS Related tasks
##############################################################################

gulp.task "scss-lint", ->
    gulp.src(paths.sass.concat("!#{paths.app}/styles/shame/**/*.scss"))
        .pipe(cache("scsslint"))
        .pipe(gulpif(!isDeploy, scsslint({config: "scsslint.yml"})))

gulp.task "sass-compile", ["scss-lint"], ->
    gulp.src(paths.sass)
        .pipe(plumber())
        .pipe(changed(paths.tmp, {extension: ".css"}))
        .pipe(insert.prepend('@import "dependencies";'))
        .pipe(sass({
            "sourcemap=none": true,
            loadPath: [
                "#{paths.app}styles/extras/"
            ]
        }))
        .pipe(gulp.dest(paths.tmp))

csslintChannel = lazypipe()
    .pipe(csslint, "csslintrc.json")
    .pipe(csslint.reporter)

gulp.task "css-lint-app", ->
    gulp.src(mainSass.concat(["#{paths.tmp}plugins/**/*.css"]))
        .pipe(cache("csslint"))
        .pipe(gulpif(!isDeploy, csslintChannel()))

gulp.task "css-join", ["css-lint-app"], ->
    gulp.src(mainSass.concat(["#{paths.tmp}plugins/**/*.css"]))
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

gulp.task "styles", ["css-app", "css-vendor"], ->
    _paths = [
        paths.tmp + "vendor.css",
        paths.tmp + "app.css"
    ]

    gulp.src(_paths)
        .pipe(concat("main.css"))
        .pipe(gulpif(isDeploy, minifyCSS({noAdvanced: true})))
        .pipe(gulp.dest(paths.dist + "styles/"))

##############################################################################
# JS Related tasks
##############################################################################

gulp.task "conf", ->
    gulp.src(["conf/conf.example.json"])
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "app-loader", ->
    gulp.src("app-loader/app-loader.coffee")
        .pipe(replace("___VERSION___", (new Date()).getTime()))
        .pipe(coffee())
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "locales", ->
    gulp.src("app/locales/en/app.json")
        .pipe(wrap("angular.module('taigaBase').value('localesEn', <%= contents %>);", {}, {parse: false}))
        .pipe(rename("locales.en.js"))
        .pipe(gulp.dest(paths.tmp))

gulp.task "coffee", ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(changed(paths.tmp, {extension: ".js"}))
        .pipe(coffee())
        .pipe(gulp.dest(paths.tmp))

gulp.task "plugins-js", ->
    gulp.src("#{paths.app}plugins/**/*.js")
        .pipe(gulp.dest(paths.tmp))

gulp.task "jslibs-watch", ->
    gulp.src(paths.libs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "jslibs-deploy", ->
    gulp.src(paths.libs)
        .pipe(plumber())
        .pipe(sourcemaps.init())
        .pipe(concat("libs.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(sourcemaps.write("./"))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "app-watch", ["coffee", "plugins-js", "conf", "locales", "app-loader"], ->
    _paths = paths.js.concat("#{paths.tmp}locales.en.js")

    gulp.src(_paths)
        .pipe(concat("app.js"))
        .pipe(gulp.dest(paths.dist + "js/"))

gulp.task "app-deploy", ["coffee", "plugins-js", "conf", "locales", "app-loader"], ->
    _paths = paths.js.concat("#{paths.tmp}locales.en.js")

    gulp.src(_paths)
        .pipe(sourcemaps.init())
            .pipe(concat("app.js"))
            .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(sourcemaps.write("./"))
        .pipe(gulp.dest(paths.dist + "js/"))

##############################################################################
# Common tasks
##############################################################################

# SVG
gulp.task "copy-svg", ->
    gulp.src("#{paths.app}/svg/**/*")
        .pipe(gulp.dest("#{paths.dist}/svg/"))

gulp.task "copy-fonts", ->
    gulp.src("#{paths.app}/fonts/*")
        .pipe(gulp.dest("#{paths.dist}/fonts/"))

gulp.task "copy-images", ->
    gulp.src("#{paths.app}/images/**/*")
        .pipe(gulpif(isDeploy, imagemin({progressive: true})))
        .pipe(gulp.dest("#{paths.dist}/images/"))

    gulp.src("#{paths.app}/plugins/**/images/*")
        .pipe(flatten())
        .pipe(gulp.dest("#{paths.dist}/images/"))

gulp.task "copy-plugin-templates", ->
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
    gulp.watch(paths.sass, ["styles"])
    gulp.watch(paths.svg, ["copy-svg"])
    gulp.watch(paths.coffee, ["app-watch"])
    gulp.watch(paths.js, ["jslibs-watch"])
    gulp.watch(paths.locales, ["app-watch"])
    gulp.watch(paths.images, ["copy-images"])
    gulp.watch(paths.fonts, ["copy-fonts"])

if isDeploy
    del.sync(paths.tmp)

gulp.task "deploy", [
    "copy",
    "jade-deploy",
    "app-deploy",
    "jslibs-deploy",
    "styles"
]

# The default task (called when you run gulp from cli)
gulp.task "default", [
    "copy",
    "styles",
    "app-watch",
    "jslibs-watch",
    "jade-deploy",
    "express",
    "watch"
]
