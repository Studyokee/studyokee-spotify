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
            app: {
                files: {
                    src: ['**/*.coffee','!node_modules/**/*']
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
