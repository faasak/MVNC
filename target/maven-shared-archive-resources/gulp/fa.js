'use strict';

// FontAwesome Font and SCSS related gulp tasks

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
var sequence = require('run-sequence');
const { gulpSassError } = require('gulp-sass-error');
const throwError = true;

var CONFIG = require('./gulp-config.js');

gulp.task('fa', function(cb) {
	sequence('copy:fa', 'scss:fa'); // sequence not needed here
});

gulp.task('scss:fa', function() {
  return gulp.src(CONFIG.SASS_FA_SRCS)
    .pipe(debug({title: 'scss:fa'}))
    .pipe(sourcemaps.init())
    .pipe(plumber())
    .pipe(sass({
	    style: 'expanded',
	    errLogToConsole: true,
	    includePaths: CONFIG.SASS_INCLUDE_PATHS
    }).on('error', gulpSassError(throwError)))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(CONFIG.CSS_DEST_PATH))
    .pipe(debug({title: 'scss:fa:result'}))
    //.on('finish', ['scss:fa:lint'])
});

gulp.task('scss:fa:lint', function () {
	return gulp.src(CONFIG.SASS_FA_SRCS)
		.pipe(sassLint({
			config: 'maven-shared-archive-resources/etc/sass-lint.yml'
		}))
		.pipe(sassLint.format());
});

// copies fonts
gulp.task('copy:fa', function() {
  return gulp.src(CONFIG.FONT_FA_SRCS)
    .pipe(rename(function(path) {
	    path.basename = 'FontAwesome';
    }))
    .pipe(gulp.dest(CONFIG.FONT_FA_DEST_PATH))
    .pipe(debug({title: 'copy:fa'}));
});
