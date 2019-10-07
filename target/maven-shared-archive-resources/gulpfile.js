
var requireDir = require('require-dir');
var gulp = require('gulp');
var browser = require('browser-sync').create('Szoo Devel');
var resolve = require('path').resolve;
var port = process.env.SERVER_PORT || 3000;

requireDir('./gulp');

//gulp.task('build', ['scss', 'javascript']);
gulp.task('build', ['scss']);

// Starts a BrowerSync (http test server) instance
gulp.task('serve', ['build'], function () {
	browser.init({
		open: false,
		injectChanges: true,
		directory: true,
		server: resolve('http-server'),
		reloadDebounce: 2000,
		port: port
		, rewriteRules: [// rewriteRules only affects html, not css....
			{match: /#\{headtitle\}/g, replace: 'devel'}
			//	{
			//		match: /#\{resource\[\'(.+?):(.+?)\'\]\}/g,
			//		replace: 'resources/$1/$2'
			//	}
		]
	});
});

// Watch files for changes, snippet inject only in files with .html extension
gulp.task('watch', function () {
	gulp.watch('../src/main/scss/**/*', ['scss']);
	gulp.watch('classes/META-INF/resources/szoo/styles/**/[a-z]*.css', ['devel:install-css-quick:szoo']);
	gulp.watch('../src/test/asciidoctor/**/*.xhtml', ['devel:test']);
	gulp.watch('http-server/**/*', browser.reload);
	// if gulpfile itself gets modified, stop old gulp watcher
	gulp.watch('gulpfile.js').on('change', () => process.ext(0));
});

// Runs all of the above tasks and then waits for files to change
gulp.task('default', ['serve', 'watch']);
