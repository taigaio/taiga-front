gulp = require("gulp")
jade = require("gulp-jade")

coffee = require("gulp-coffee")
concat = require("gulp-concat")
uglify = require("gulp-uglify")
plumber = require("gulp-plumber")
wrap = require("gulp-wrap")
rename = require("gulp-rename")

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

paths = {
    app: "app"
    dist: "dist"
    html: "app/*.html"
    jade: ["app/index.jade", "app/partials/**/*.jade"]
    scssStyles: "app/styles/**/*.scss"
    distStylesPath: "dist/styles"
    distStyles: ["dist/styles/vendor.css",
                 "dist/styles/app.css"]
    sassStylesMain: "app/styles/main.scss"
    css:  "app/styles/vendor/*.css"
    images: "app/images/**/*"
    svg: "app/svg/**/*"
    locales: "app/locales/**/*.json"
    coffee: ["app/coffee/app.coffee",
             "app/config/*.coffee",
             "app/coffee/*.coffee",
             "app/coffee/modules/controllerMixins.coffee",
             "app/coffee/modules/*.coffee",
             "app/coffee/modules/common/*.coffee",
             "app/coffee/modules/backlog/*.coffee",
             "app/coffee/modules/taskboard/*.coffee",
             "app/coffee/modules/kanban/*.coffee",
             "app/coffee/modules/issues/*.coffee",
             "app/coffee/modules/userstories/*.coffee",
             "app/coffee/modules/tasks/*.coffee",
             "app/coffee/modules/wiki/*.coffee",
             "app/coffee/modules/admin/*.coffee",
             "app/coffee/modules/projects/*.coffee",
             "app/coffee/modules/locales/*.coffee",
             "app/coffee/modules/base/*.coffee",
             "app/coffee/modules/resources/*.coffee",
             "app/coffee/modules/user-settings/*.coffee"
             "app/plugins/**/*.coffee"]
    vendorJsLibs: [
        "app/vendor/jquery/dist/jquery.js",
        "app/vendor/lodash/dist/lodash.js",
        "app/vendor/emoticons/lib/emoticons.js",
        "app/vendor/underscore.string/lib/underscore.string.js",
        "app/vendor/angular/angular.js",
        "app/vendor/angular-route/angular-route.js",
        "app/vendor/angular-sanitize/angular-sanitize.js",
        "app/vendor/angular-animate/angular-animate.js",
        "app/vendor/i18next/i18next.js",
        "app/vendor/moment/min/moment-with-langs.js",
        "app/vendor/checksley/checksley.js",
        "app/vendor/pikaday/pikaday.js",
        "app/vendor/jquery-flot/jquery.flot.js",
        "app/vendor/jquery-flot/jquery.flot.pie.js",
        "app/vendor/jquery-flot/jquery.flot.time.js",
        "app/vendor/jquery-flot/jquery.flot.time.js",
        "app/vendor/flot-axislabels/jquery.flot.axislabels.js",
        "app/vendor/jquery-textcomplete/jquery.textcomplete.js",
        "app/vendor/markitup/markitup/jquery.markitup.js",
        "app/vendor/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.concat.min.js",
        "app/js/jquery.ui.git.js",
        "app/js/sha1.js",
        "app/plugins/**/*.js"
    ]
}

############################################################################
# Layout/CSS Related tasks
##############################################################################

gulp.task "jade-deploy", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cache("jade"))
        .pipe(jade({pretty: false}))
        .pipe(gulp.dest("#{paths.dist}/partials"))

gulp.task "jade-watch", ->
    gulp.src(paths.jade)
        .pipe(plumber())
        .pipe(cache("jade"))
        .pipe(jadeInheritance({basedir: './app'}))
        .pipe(jade({pretty: true}))
        .pipe(gulp.dest("#{paths.dist}"))

gulp.task "template", ->
    gulp.src("#{paths.app}/index.jade")
        .pipe(plumber())
        .pipe(jade({pretty: true, locals:{v:(new Date()).getTime()}}))
        .pipe(gulp.dest("#{paths.dist}"))

gulp.task "sass-lint", ->
    gulp.src([paths.scssStyles, '!app/styles/bourbon/**/*.scss'])
        .pipe(cache("sasslint"))
        .pipe(scsslint({config: "scsslint.yml"}))

gulp.task "sass-watch", ["sass-lint"], ->
    gulp.src(paths.sassStylesMain)
        .pipe(plumber())
        .pipe(sass())
        .pipe(rename("app.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "sass-deploy", ->
    gulp.src(paths.sassStylesMain)
        .pipe(plumber())
        .pipe(sass())
        .pipe(rename("app.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "css-vendor", ->
    gulp.src(paths.css)
        .pipe(concat("vendor.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "css-lint-app", ["sass-watch"],  ->
    gulp.src(paths.distStylesPath + "/app.css")
        .pipe(csslint("csslintrc.json"))
        .pipe(csslint.reporter())

gulp.task "styles-watch", ["sass-watch", "css-vendor", "css-lint-app"], ->
    gulp.src(paths.distStyles)
        .pipe(concat("main.css"))
        .pipe(gulp.dest(paths.distStylesPath))

gulp.task "styles-deploy", ["sass-deploy", "css-vendor"], ->
    gulp.src(paths.distStyles)
        .pipe(concat("main.css"))
        .pipe(minifyCSS())
        .pipe(gulp.dest(paths.distStylesPath))

##############################################################################
# JS Related tasks
##############################################################################

gulp.task "locales", ->
    gulp.src("app/locales/en/app.json")
        .pipe(wrap("angular.module('taigaLocales').constant('localesEnglish', <%= contents %>);"))
        .pipe(rename("localeEnglish.coffee"))
        .pipe(gulp.dest("app/coffee/modules/locales"))

    # gulp.src("app/locales/es/app.json")
    #     .pipe(wrap("angular.module('locales.es', []).constant('locales.es', <%= contents %>);"))
    #     .pipe(rename("locale.es.coffee"))
    #     .pipe(gulp.dest("app/coffee/"))

gulp.task "coffee-watch", ["locales"], ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(coffee())
        .pipe(concat("app.js"))
        .pipe(gulp.dest("dist/js/"))

gulp.task "coffee-deploy", ["locales"], ->
    gulp.src(paths.coffee)
        .pipe(plumber())
        .pipe(coffee())
        .pipe(concat("app.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(gulp.dest("dist/js/"))

gulp.task "jslibs-watch", ->
    gulp.src(paths.vendorJsLibs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(gulp.dest("dist/js/"))

gulp.task "jslibs-deploy", ->
    gulp.src(paths.vendorJsLibs)
        .pipe(plumber())
        .pipe(concat("libs.js"))
        .pipe(uglify({mangle:false, preserveComments: false}))
        .pipe(gulp.dest("dist/js/"))

##############################################################################
# Common tasks
##############################################################################

# SVG
gulp.task "svg",  ->
    gulp.src("#{paths.app}/svg/**/*")
        .pipe(gulp.dest("#{paths.dist}/svg/"))

# Copy Files
gulp.task "copy",  ->
    gulp.src("#{paths.app}/fonts/*")
        .pipe(gulp.dest("#{paths.dist}/fonts/"))

    gulp.src("#{paths.app}/images/**/*")
        .pipe(gulp.dest("#{paths.dist}/images/"))

    gulp.src("#{paths.app}/plugins/**/templates/*")
        .pipe(gulp.dest("#{paths.dist}/plugins/"))


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
    gulp.watch("#{paths.app}/index.jade", ["template"])
    gulp.watch(paths.scssStyles, ["styles-watch"])
    gulp.watch(paths.svg, ["svg"])
    gulp.watch(paths.coffee, ["coffee-watch"])
    gulp.watch(paths.vendorJsLibs, ["jslibs-watch"])
    gulp.watch(paths.locales, ["coffee-watch"])

gulp.task "deploy", [
    "jade-deploy",
    "template",
    "copy",
    "svg",
    "coffee-deploy",
    "jslibs-deploy",
    "styles-deploy"
]

# The default task (called when you run gulp from cli)
gulp.task "default", [
    "jade-deploy",
    "template",
    "styles-watch",
    "svg",
    "copy",
    "coffee-watch",
    "jslibs-watch",
    "express",
    "watch"
]
