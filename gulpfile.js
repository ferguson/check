var gulp = require('gulp');

var jshint = require('gulp-jshint');
var coffeelint = require('gulp-coffeelint');
var csslint = require('gulp-csslint');
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var minifycss = require('gulp-minify-css');
var rename = require('gulp-rename');
var sourcemaps = require('gulp-sourcemaps');
var webserver = require('gulp-webserver');
var coffee = require('gulp-coffee');
var jsx = require('gulp-react');
var gutil = require('gulp-util'); 
var debug = require('gulp-debug');
var del = require('del');
var prompt = require('prompt');
var watchify = require('watchify');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');


// default - build all the things
gulp.task('default', ['coffee', 'sass', 'copyjs', 'copycss', 'lint', 'bundle', 'minify']);


// coffee - CoffeeScript + JSX conversion to .js files in js/
gulp.task('coffee', ['lintcoffee'], function() {
    return gulp.src('src/*.coffee')
        //.pipe(sourcemaps.init())  // was breaking JSX transform?
        .pipe(coffee({ bare: true })).on('error', gutil.log)
        //.pipe(sourcemaps.write('maps'))
        .pipe(jsx()).on('error', gutil.log)
        .pipe(gulp.dest('js'));
});


// bundle - bundle .js and .css files into bundle.js and bundle.css
gulp.task('bundle', ['bundlejs', 'bundlecss']);


var bundle = function() {
    return bundler.bundle()
        .on('error', gutil.log.bind(gutil, 'Browserify Error'))
        .pipe(source('bundle.js'))
        .pipe(buffer())
        .pipe(sourcemaps.init({loadMaps: true})) // loads map from browserify file
        .pipe(sourcemaps.write('./')) // writes .map file
        .pipe(gulp.dest('./bundle'));
};

var bundler = browserify('./js/index.js', {});
bundler.transform('brfs');
//var bundler = watchify(browserify('./js/index.js', watchify.args));  // 
//bundler.on('update', bundle);  // on any dep update, runs the bundler  // for watchify
bundler.on('log', gutil.log);  // output build logs to terminal

// bundlejs - Browserify everything into one bundle.js file in bundle/
gulp.task('bundlejs', ['coffee'], bundle);


// bundlecss - bundle .css files into one bundle.css in bundle/
//   warning: will be in filename sorted order
//   00name.css 01name.css filenames might be useful here
gulp.task('bundlecss', ['sass', 'lintcss'], function() {
  return gulp.src('css/*.css')
    .pipe(concat('bundle.css'))
    .pipe(gulp.dest('bundle'));
});


// minify - make bundle.min.js and bundle.min.css
//   client doesn't currently use minified files (FIXME for production)
gulp.task('minify', ['minifyjs', 'minifycss']);


// minifyjs - make a minified version of bundle.js
gulp.task('minifyjs', ['bundlejs'], function() {
    return gulp.src('bundle/bundle.js')
        .pipe(rename('bundle.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('bundle'));
});


// minifycss - make a minified version of bundle.css
gulp.task('minifycss', ['bundlecss'], function() {
  return gulp.src('bundle/bundle.css')
    .pipe(minifycss( {keepBreaks:false} ))  // keepBreaks:true might be useful
    .pipe(rename('bundle.min.css'))
    .pipe(gulp.dest('bundle'));
});


// sass - convert sass into css
gulp.task('sass', function() {
    return gulp.src('src/*.sass')
        .pipe(sass( {indentedSyntax: true} )).on('error', gutil.log)  // indentedSyntax:true makes it sass (vs. scss)
        .pipe(gulp.dest('css'));
});


// copyjs - copy .js files from src/ to js/
gulp.task('copyjs', function(cb) {
    gulp.src('src/*.js')
        .pipe(gulp.dest('./js'), cb);
});


// copycss - copy .css files from src/ to css/
gulp.task('copycss', function(cb) {
    gulp.src('src/*.css')
        .pipe(gulp.dest('./css'), cb);
});


// lint - run everything through as many linters as possible/practical
gulp.task('lint', ['lintcoffee', 'lintjs', 'lintjson', 'lintgulpfile', 'lintcss']);


// lintcoffee - lint the coffeescript
gulp.task('lintcoffee', function() {
    return gulp.src('src/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter());
});


// lintjs - lint the generated js using jshint
//   less useful than normal since coffeescript prevents so many lintable things
//   (and generates a few of it's own) but still catches some stuff
gulp.task('lintjs', ['coffee'], function() {
    return gulp.src('js/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});


// lintjson - run all our project's json scaffolding through jshint
gulp.task('lintjson', function() {
    return gulp.src('*.json')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});


// lintgulpfile - lint ourself!
gulp.task('lintgulpfile', function() {
    return gulp.src('gruntfile.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'));
});


// lintcss - lint all the css files, generated and otherwise
gulp.task('lintcss', function() {
    gulp.src(['css/*.css', '!css/ouroboros.css'])  // ouroboros not ready to be linted
        .pipe(csslint({"box-model": false, "box-sizing": false, "adjoining-classes": false}))
        .pipe(csslint.reporter());
});


// clean - remove unwanted cruft
//   warning: removes the js and css directories!
//   don't put source files there! put them in /src
//   (and, if needed, add gulp rules for copying them into js/ and css/)
gulp.task('clean', function (cb) {
    prompt.start();
    areYouSure(cb, function() {
        do_clean(cb);
    });
});


// distclean - remove everything possible
//   see warning under 'clean' above
//   you will need to run ./setup again from scratch
gulp.task('distclean', function (cb) {
    prompt.start();
    areYouSure(cb, function() {
        do_distclean(cb);
    });
});

var do_clean = function(cb) {
    del(['js', 'css', 'bundle', '*~', '*/*~', '.??*~', 'npm-debug.log']);
    cb();
};

var do_distclean = function(cb) {
    do_clean(function() {
        del(['activate', 'bin', 'include', 'lib', 'n', 'node_modules', 'share', 'tmp']);
    });
    cb();
};

var areYouSure = function(no_cb, yes_cb) {
    console.log('Warning: this deletes things, including the js/ and css/ directories.');
    prompt.get({properties: { sure: { description: 'Are you sure? [y/N]'}}},
        function(err, result) {
            if (!err && (result.sure.toLowerCase() === 'y')) {
                console.log('cleaning...');
                yes_cb();
            } else {
                console.log('clean aborted.');
                no_cb();
            }
        });
};


// watch - build things when things change
gulp.task('watch', function() {
    //gulp.watch('src/*', ['default']);
    gulp.watch('src/*.coffee', ['coffee', 'lintcoffee', 'lintjs', 'bundlejs']);
    gulp.watch('src/*.js',     ['copyjs', 'lintjs', 'bundlejs']);
    gulp.watch('src/*.sass',   ['sass', 'lintcss', 'bundlecss']);
    gulp.watch('src/*.css',    ['copycss', 'lintcss', 'bundlecss']);
});


// debug - debugging broken file globbing
gulp.task('debug', function() {
    gulp.src(['src/*.coffee', '!src/.#*'])
        .pipe(debug());
});


// webserver - serve up index.html and friends on localhost:8000
gulp.task('webserver', [], function() {
    return gulp.src('./')
        .pipe(webserver({
            //host: '0.0.0.0',  // for mobile testing :)
            directoryListing: false,  // disabled to force it to serve index.html by default
            livereload: {
                enable: true,  // enables livereload 
                //enable: false,  // it reloads the previous version which is not helpful
                filter: function(filename) {
                    // only reload on the files specific to the browser
                    //console.log(filename);
                    if (filename.match(/\/bundle$|\/static$|index.html$/)) {
                        console.log('live', filename);
                        return true;
                    } else {
                        return false;
                    }
                }
            },
            open: true
        }));
});
