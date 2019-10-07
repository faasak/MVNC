// Gulp working dir is $basedir/target.
// Gulpfile in working dir, node_modules (link) in working dir.
// Every relative path below originates at the working dir.

module.exports = {

	// Javascript
	JS_FILES: [
		'js/foundation.core.js',
		'js/foundation.util.core.js',
		'js/foundation.util.*.js',
		'js/*.js'
	],

	JS_DEPS: [
		'node_modules/jquery/dist/jquery.js',
		'node_modules/motion-ui/dist/motion-ui.js',
		'node_modules/what-input/dist/what-input.js'
	],

	JS_DOCS: [
		'node_modules/clipboard/dist/clipboard.js',
		'node_modules/corejs-typeahead/dist/typeahead.bundle.js',
		'node_modules/foundation-docs/js/**/*.js',
		'docs/assets/js/docs.*.js',
		'docs/assets/js/docs.js'
	],

	// Sass SCSS

	// Base dirs, in combination with relative paths of
	// @import directives they point to resource.
	// Lookup in order until resource found.
	SASS_INCLUDE_PATHS: [
		// custom styles factory
		'../src/main/scss',
		'../src/main/scss/szoo',
		'../src/main/scss/font-awesome',
		// used for font awesome right now
		'generated-sources/scss',
		'generated-sources/scss/font-awesome',
		// defaults which come with artifact
		'maven-shared-archive-resources/main/scss',
		'maven-shared-archive-resources/main/scss/szoo',
		// defaults from github sources and npm
		'../src/github_repos/foundation-sites/scss',
		'node_modules'
	],

	SASS_SZOO_SRCS: [
		'../src/main/scss/szoo/**/*.scss',
		'maven-shared-archive-resources/main/scss/szoo/**/*.scss'
	],

	SASS_FA_SRCS: [
		'maven-shared-archive-resources/main/scss/font-awesome/**/*.scss',
		'generated-sources/scss/font-awesome/*.scss',
		'../src/main/scss/font-awesome/*.scss'
	],

	FONT_FA_SRCS: [
		'node_modules/font-awesome/fonts/f*'
	],

	CSS_COMPATIBILITY: [
		'last 2 versions',
		'ie >= 9',
		'Android >= 2.3',
		'ios >= 7'
	],

	// Sass compiler output dir
	LOCAL_PATH: '../src',
	SHARE_PATH: 'maven-shared-archive-resources',
	CSS_DEST_PATH: 'classes/META-INF/resources/szoo/styles',
	FONT_FA_DEST_PATH: 'classes/META-INF/resources/szoo/fonts/FontAwesome',

	// styles, fonts, js et al
	DIST_RESOURCES_PATH: 'classes/META-INF/resources/szoo',
	DEVEL_RESOURCES_PATH: 'http-server/resources/szoo',
	DEVEL_RESOURCES_STYLES_PATH: 'http-server/resources/szoo/styles',
	DEVEL_HTML_DEST: 'http-server',
	DEVEL_COMPOSITION_SRCS: [
		'../src/test/asciidoctor/composition-template.xhtml',
		'maven-shared-archive-resources/test/asciidoctor/composition-template.xhtml'
	],
	DEVEL_COMPOSITION_TEMPLATE: 'http-server/composition-template.xhtml',
	DEVEL_ADOC_SRCS: [
		'../src/test/asciidoctor/*.adoc',
		'maven-shared-archive-resources/test/asciidoctor/*.adoc'
	]

};


