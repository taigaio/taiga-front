var gulp = require('gulp'),
    jade = require('gulp-jade'),
    newer = require('gulp-newer'),
    minifyHTML = require('gulp-minify-html'),
    sass = require('gulp-ruby-sass'),
    csslint = require('gulp-csslint'),
    minifyCSS = require('gulp-minify-css'),
    imagemin = require('gulp-imagemin'),
    watch = require('gulp-watch'),
    size = require('gulp-filesize'),
    notify = require("gulp-notify"),
    connect = require('gulp-connect'),
    scsslint = require('gulp-scss-lint'),
    newer = require('gulp-newer')
    cache = require('gulp-cached');

var paths = {
    app: 'app',
    dist: 'dist',
    html: 'app/*.html',
    jade: 'app/**/*.jade',
    appStyles: 'app/styles/**/*.scss',
    distStyles: 'dist/styles',
    sassMain: 'app/styles/main.scss',
    css:  'dist/styles/**/*.css',
    images: 'app/images/**/*'
};

gulp.task('jade', function() {
  return gulp.src(paths.jade)
    .on('error', function(err) {
        console.log(err);
    })
    .pipe(jade({
      pretty: true
    }))
    .pipe(gulp.dest(paths.dist))
    .pipe(size());
});

//Sass lint
gulp.task('scss-lint', function() {
  gulp.src([paths.appStyles, '!/**/bourbon/**/*.scss'])
        .pipe(cache('scsslint'))
        .pipe(scsslint({config: 'scsslint.yml'}))
});

//Sass Files
gulp.task('sass', function () {
    return gulp.src(paths.sassMain)
    .pipe(sass().on('error', function(err) {
        console.log(err);
    }))
    .pipe(gulp.dest(paths.distStyles))
    .pipe(size());
});

//CSS Linting and report
gulp.task('css', ['sass'], function() {
  gulp.src([paths.css, '!'+paths.dist+'/styles/vendor/**/*.css'])
    .pipe(csslint('csslintrc.json'))
    .pipe(csslint.reporter());
});


//Minify CSS
gulp.task('minifyCSS', ['css', 'sass'], function () {
    gulp.src('dist/styles/main.css')
        .pipe(minifyCSS())
        .pipe(gulp.dest(paths.distStyles))
        .pipe(size());
});

gulp.task('imagemin', function () {
    return gulp.src(paths.images)
        .pipe(imagemin({
            progressive: true
        }).on('error', function(err) {
            console.log(err);
        }))
        .pipe(gulp.dest(paths.dist+'/images'));
});

//Copy Files
gulp.task('copy', ['sass', 'css'], function() {
    //Copy vendor styles
    gulp.src(paths.app+'/styles/vendor/**/*.css')
        .pipe(gulp.dest(paths.dist+'/styles/vendor/'));
    //Copy fonts
    gulp.src(paths.app+'/fonts/*')
        .pipe(gulp.dest(paths.dist+'/fonts/'));
});

gulp.task('connect', function() {
    connect.server({
        root: paths.dist,
        livereload: true
    });
});

// Rerun the task when a file changes
gulp.task('watch', function() {
    gulp.watch(paths.jade, ['jade']);
    gulp.watch(paths.appStyles, ['scss-lint', 'sass', 'css']);
});

// The default task (called when you run `gulp` from cli)
gulp.task('default', [
    'jade',
    'sass',
    'css',
    'copy',
    'connect',
    'watch'
]);

// The default task (called when you run `gulp` from cli)
gulp.task('dist', [
    'jade',
    'sass',
    'css',
    'minifyCSS',
    'imagemin',
    'copy',
    'connect',
    'watch'
]);
