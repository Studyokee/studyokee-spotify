'use strict';

module.exports = function (grunt) {
    require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    grunt.initConfig({
        watch: {
            coffee: {
                files: [
                    'src/*.coffee'
                ],
                tasks: [
                    'coffeelint',
                    'coffee'
                ]
            },
            lib: {
                files: [
                    '**/*.js',
                    '**/*.css',
                    '**/*.html',
                    '!node_modules/**/*',
                    '!components/**/*'
                ],
                options: {
                    livereload: true
                }
            }
        },
        coffee: {
            compile: {
                src: ['src/*.coffee'],
                dest: 'lib/',
                ext: '.js',
                expand: true,
                flatten: true,
                options: {
                    runtime: 'inline',
                    sourceMap: true
                }
            }
        },
        coffeelint: {
            app: {
                files: {
                    src: [
                        '**/*.coffee',
                        '!components/**/*', 
                        '!node_modules/**/*'
                    ]
                },
                options: {
                    max_line_length: {
                        level: 'warn'
                    }
                }
            }
        }
    });

    grunt.registerTask('default', ['coffeelint', 'coffee', 'watch']);
};
