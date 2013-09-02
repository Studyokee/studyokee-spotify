'use strict';

module.exports = function (grunt) {
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    grunt.initConfig({
        watch: {
            coffee: {
                files: ['src/*.coffee'],
                tasks: ['coffeelint', 'coffee']
            }
        },
        coffee: {
            compile: {
                src: ['src/*.coffee'],
                dest: 'lib/',
                ext: '.js',
                expand: true,
                flatten: true
            }
        },
        coffeelint: {
            app: ['**/*.coffee','!node_modules/**/*']
        }
    });

    grunt.registerTask('default', ['coffeelint', 'coffee', 'watch']);
};
