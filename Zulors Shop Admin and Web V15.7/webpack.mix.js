const fs = require('fs');
const mix = require('laravel-mix');

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel application. By default, we are compiling the Sass
 | file for the application as well as bundling up all the JS files.
 |
 */

mix.js('resources/js/app.js', 'public/js');

// Some distributed app versions contain the compiled stylesheet but not its
// Sass source. Keep the JS production build usable without overwriting that CSS.
const sassEntry = 'resources/sass/app.scss';
if (fs.existsSync(sassEntry)) {
    mix.sass(sassEntry, 'public/css');
}
