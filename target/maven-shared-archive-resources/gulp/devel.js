'use strict';

// Tasks for creating development http-server area.
// Reads all from distribution target/classes, copies it to target/http-server
// and also converts JSF EL resource descriptors to relative paths.
// For test, it creates some html files from asciidoctor sources.
// Html files are also wrapped into a composition template like
// it gets used in JSF.

var browser = require('browser-sync').get('Szoo Devel');
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
var replace = require("gulp-replace");
var asciidoctor = require("gulp-asciidoctor");
var exec = require("gulp-exec");
var sequence = require('run-sequence');

var CONFIG = require('./gulp-config.js');

// Populates http server style development area
gulp.task('devel', ['devel:install-css-resrc', 'devel:test', 'devel:install-other-resrc']);
//4.0.0 gulp.task('devel:test', gulp.series('devel:adoc', 'devel:tidy', 'devel:comp'));
// tasks for dynamic files
gulp.task('devel:test', function (done) {
	sequence('devel:composition', 'devel:adoc', 'devel:tidy', 'devel:comp', done);
});

// Copies all CSS and converts EL resources to path
gulp.task('devel:install-css-resrc', function () {
	return gulp.src(path.join(CONFIG.DIST_RESOURCES_PATH, 'styles/**/*.css'))
		.pipe(replace(/#{resource\['(.+?):fonts\/(.+?)'\]}/g, '../../$1/fonts/$2'))
		.pipe(gulp.dest(CONFIG.DEVEL_RESOURCES_STYLES_PATH))
		.pipe(debug({title: 'devel:css'}));
});

// Faster subset of devel:css no font css
gulp.task('devel:install-css-quick:szoo', function () {
	return gulp.src(path.join(CONFIG.DIST_RESOURCES_PATH, 'styles/**/[a-z]*.css'))
		.pipe(gulp.dest(CONFIG.DEVEL_RESOURCES_STYLES_PATH))
		.pipe(debug({title: 'devel:css'}));
});

gulp.task('devel:install-other-resrc', function () {
	return gulp.src([
        	path.join(CONFIG.DIST_RESOURCES_PATH, '**'),
		    '!' + path.join(CONFIG.DIST_RESOURCES_PATH, 'styles/**/*.css')
		])
		.pipe(gulp.dest(CONFIG.DEVEL_RESOURCES_PATH))
		.pipe(debug({title: 'devel:others'}))
		.pipe(browser.stream());
});

// pick shared/local composition template
gulp.task('devel:composition', function () {
	return gulp.src(CONFIG.DEVEL_COMPOSITION_SRCS)
		.pipe(gulp.dest(CONFIG.DEVEL_HTML_DEST));
});

gulp.task('devel:adoc', function () {
	return gulp.src(CONFIG.DEVEL_ADOC_SRCS)
		.pipe(debug({title: 'devel:adoc'}))
		.pipe(asciidoctor({
			safe: 'unsafe',
			//attributes: ['linkcss' ],
			backend: 'xhtml5',
			stylesheet: 'szoo.css',
			stylesdir: path.join(CONFIG.DEVEL_RESOURCES_PATH, 'styles'),
			source_highlighter: 'pygments',
			imagesdir: 'images',
			icons: 'image',
			header_footer: true
		}))
		.pipe(gulp.dest(CONFIG.DEVEL_HTML_DEST))
		.pipe(debug({title: 'devel:adoc'}));
});


// no output with numeric option, cannot get plugin to work
//gulp.task('devel:tidy', function () {
//	return gulp.src(['../target/http-server/test1.html'])
//		.pipe(debug({title: 'devel:tidy'}))
//		.pipe(tidy({
//			doctype: 'xhtml5',
//			indent: true
//		}))
//		.pipe(gulp.dest('../target/http-server/x'));
//});
gulp.task('devel:tidy', function () {
	var options = {
		silent: false,
		continueOnError: true,
		pipeStdout: true
	};
	var reportOptions = {
		err: true,
		stderr: false,
		stdout: false
	};
	return gulp.src(path.join(CONFIG.DEVEL_HTML_DEST, 'test?.html'))
		.pipe(exec('tidy --drop-empty-elements no -q -i -numeric ' +
		' -f <%= file.path %>.tidylog ' +
		' -asxhtml <%= file.path %> || true', options))
		.pipe(rename(function(path) {
			path.extname = ".tidy.html";
		}))
		.pipe(gulp.dest(CONFIG.DEVEL_HTML_DEST))
		.pipe(debug({title: 'devel:comp'}))
		.pipe(exec.reporter(reportOptions));
});

// cannot get this plugin to work:
//gulp.task('devel:xhtml', function (cb) {
//	return gulp.src('test/asciidoctor/composition-template.xhtml')
//		.pipe(debug({title: 'devel:comp'}))
//		.pipe(xslt('./etc/merge-adocbody.xsl', {
//			xhtmlfile: xhtmlfile
//		}))
//		.pipe(gulp.dest('../target/http-server/y'));
//
// unsing exec instead, would be from inside http-server dir:
// xsltproc --stringparam xhtmlfile file://$PWD/test1.html ../../src/bash/merge-adocbody.xsl \
//   ../../src/test/asciidoctor/composition-template.xhtml
gulp.task('devel:comp', function () {
	var options = {
		silent: false,
		continueOnError: false, // default = false, true means don't emit error event
		pipeStdout: true // default = false, true means stdout is written to file.contents
	};
	var reportOptions = {
		err: true, // default = true, false means don't write err
		stderr: true, // default = true, false means don't write stderr
		stdout: false // default = true, false means don't write stdout
	};
	return gulp.src(path.join(CONFIG.DEVEL_HTML_DEST, 'test?.tidy.html'))
		.pipe(exec('xsltproc --stringparam xhtmlfile <%= file.path %> '
		+ path.join(CONFIG.SHARE_PATH, 'etc/merge-adocbody.xsl')
		+ ' ' + CONFIG.DEVEL_COMPOSITION_TEMPLATE,
		options))
		.pipe(rename(function(path) {
			path.extname = ".composition.html";
		}))
		.pipe(gulp.dest(CONFIG.DEVEL_HTML_DEST))
		.pipe(debug({title: 'devel:comp'}))
		.pipe(exec.reporter(reportOptions));
});
