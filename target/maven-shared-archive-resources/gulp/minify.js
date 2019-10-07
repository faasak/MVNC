var gulp = require('gulp');
var filter = require('gulp-filter');
var cleancss = require('gulp-clean-css');
var debug = require('gulp-debug');
var rename = require('gulp-rename');
var uglify = require('gulp-uglify');
var confirm = require('gulp-prompt').confirm;
var rsync = require('gulp-rsync');
var replace = require('gulp-replace');
var octophant = require('octophant');
var sequence = require('run-sequence');
var inquirer = require('inquirer');
var exec = require('child_process').execSync;
var path = require('path');
var plumber = require('gulp-plumber');

var CONFIG = require('./gulp-config.js');
//var CURRENT_VERSION = require('../package.json').version; // TODO

gulp.task('minify', function (cb) {
	sequence('minify:dist:css', cb);
});

var cleanCssOptions = {compatibility: '*',
	level: {
		1: {
			all: true,
			roundingPrecision: 'all=2,px=3'
		},
		2: {
			all: true
		}
	},
};


gulp.task('minify:dist:css', function () {
	var cssFiles = [
		path.join(CONFIG.CSS_DEST_PATH, '**/*.css'),
		path.join('!' + CONFIG.CSS_DEST_PATH, '**/*.min.css')
	];
	return gulp.src(cssFiles)
		.pipe(cleancss(cleanCssOptions))
		.pipe(rename({suffix: '.min'}))
		.pipe(gulp.dest(CONFIG.CSS_DEST_PATH))
		.pipe(debug({title: 'minify:dist:css'}));
});

gulp.task('minify:devel:css', function () {
	var cssFiles = [
		path.join(CONFIG.DEVEL_RESOURCES_STYLES_PATH, '**/*.css'),
		path.join('!' + CONFIG.DEVEL_RESOURCES_STYLES_PATH, '**/*.min.css'),
	];
	return gulp.src(cssFiles)
		.pipe(cleancss(cleanCssOptions))
		.pipe(rename({suffix: '.min'}))
		.pipe(gulp.dest(CONFIG.DEVEL_RESOURCES_STYLES_PATH))
		.pipe(debug({title: 'minify:dist:css'}));
});

// Generates compiled CSS and JS files and puts them in the dist/ folder
//gulp.task('minify:dist', ['sass:foundation', 'javascript:foundation'], function() {
//  var cssFilter = filter([path.join(TARGET_JSF_RESOURCESDIR, '**/*.css')], { restore: true });
//  var jsFilter  = filter([path.join(TARGET_JSF_RESOURCESDIR, '**/*.js')], { restore: true });
//
//  console.log(CONFIG.DIST_FILES)
//  return gulp.src(CONFIG.DIST_FILES)
//    .pipe(plumber())
//    .pipe(cssFilter)
//      .pipe(gulp.dest('./dist/css'))
//      .pipe(cleancss({ compatibility: '*' }))
//      .pipe(rename({ suffix: '.min' }))
//      .pipe(gulp.dest('./dist/css'))
//    .pipe(cssFilter.restore)
//    .pipe(jsFilter)
//      .pipe(gulp.dest('./dist/js'))
//      .pipe(uglify())
//      .pipe(rename({ suffix: '.min' }))
//      .pipe(gulp.dest('./dist/js'));
//});

// Copies standalone JavaScript plugins to dist/ folder
//gulp.task('minify:plugins', function() {
//  gulp.src('_build/assets/js/plugins/*.js')
//    .pipe(gulp.dest('dist/js/plugins'))
//    .pipe(uglify())
//    .pipe(rename({ suffix: '.min' }))
//    .pipe(gulp.dest('dist/js/plugins'));
//});


// The Customizer runs this function to generate files it needs
//gulp.task('minify:custom', ['scss:szoo', 'javascript:szoo'], function() {
//  gulp.src('..//foundation.css')
//      .pipe(cleancss({ compatibility: '*' }))
//      .pipe(rename('foundation.min.css'))
//      .pipe(gulp.dest('./_build/assets/css'));
//
//  return gulp.src('_build/assets/js/foundation.js')
//      .pipe(uglify())
//      .pipe(rename('foundation.min.js'))
//      .pipe(gulp.dest('./_build/assets/js'));
//});
