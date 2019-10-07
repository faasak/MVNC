'use strict';

// Szoo SCSS related tasks

var fs = require('fs');
var gulp = require('gulp');
var Parker = require('parker/lib/Parker');
var prettyJSON = require('prettyjson');
var sass = require('gulp-sass');
var plumber = require('gulp-plumber');
var sourcemaps = require('gulp-sourcemaps');
var sassLint = require('gulp-sass-lint');
var postcss = require('gulp-postcss');
var autoprefixer = require('autoprefixer');
var size = require('gulp-filesize');
var debug = require('gulp-debug');
var path = require('path');
var rename = require("gulp-rename");
var flatten = require("gulp-flatten");
var gutil = require("gulp-util");
const { gulpSassError } = require('gulp-sass-error');
const throwError = true;

var CONFIG = require('./gulp-config.js');

gulp.task('scss', ['scss:szoo']);

// Compiles Foundation Scss
//gulp.task('scss:szoo', ['scss:deps'], function() {
gulp.task('scss:szoo', function () {
	return gulp.src(CONFIG.SASS_SZOO_SRCS)
		.pipe(debug({title: 'scss:szoo'}))
		.pipe(sourcemaps.init())
		.pipe(plumber())
		.pipe(sass({
			style: 'expanded',
			errLogToConsole: true,
			includePaths: CONFIG.SASS_INCLUDE_PATHS
		}).on('error', gulpSassError(throwError)))
		.pipe(debug({title: 'scss:szoo:preautoprefixer'}))
		.pipe(postcss([autoprefixer({
				browsers: CONFIG.CSS_COMPATIBILITY
			})]))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest(CONFIG.CSS_DEST_PATH))
		.pipe(debug({title: 'scss:szoo:result'}));
});

// lint will print many warnings about tabs/spaces/indent, waiting for sass-lint autofix option...
gulp.task('scss:szoo:lint', function () {
	return gulp.src(CONFIG.SASS_SZOO_SRCS)
		.pipe(sassLint({
			config: 'maven-shared-archive-resources/etc/sass-lint.yml'
		}))
		.pipe(sassLint.format());
});

// Audits CSS filesize, selector count, specificity, etc.
gulp.task('scss:audit', ['scss:szoo'], function(cb) {
  fs.readFile(path.join(CONFIG.CSS_DEST_PATH, 'szoo.css'), function(err, data) {
    var parker = new Parker(require('parker/metrics/All'));
    var results = parker.run(data.toString());
    console.log(prettyJSON.render(results));
    cb();
  });
});
