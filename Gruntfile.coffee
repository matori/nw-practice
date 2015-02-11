"use strict"

pkg = require "./package.json"

nwSrc = ->
    nwSrc = ["!./", "./package.json", "./pub/**/*"]
    for key, value of pkg.dependencies
        nwSrc.push "./node_modules/#{key}/**/*"
    nwSrc

module.exports = (grunt) ->
    grunt.initConfig

    # directories
        dir:
            src: "./src"
            dist: "./pub"
            build: "./_build"
            nw: "./_nw"

    # https://github.com/gruntjs/grunt-contrib-clean
        clean:
            dev: ["<%= dir.dist %>"]
            pub: ["<%= dir.dist %>", "<%= dir.build %>"]

    # https://github.com/gruntjs/grunt-contrib-copy
        copy:
            images:
                src: "<%= dir.src %>/images/**/*"
                dest: "<%= dir.dist %>/images"
            fonts:
                src: "<%= dir.src %>/fonts/**/*"
                dest: "<%= dir.dist %>/fonts"

    # https://github.com/gruntjs/grunt-contrib-jade
        jade:
            dev:
                options:
                    pretty: true
                    data:
                        debug: true
                files:
                    "<%= dir.dist %>/index.html": "<%= dir.src %>/index.jade"
            pub:
                options:
                    pretty: false
                    data:
                        debug: false
                files:
                    "<%= dir.dist %>/index.html": "<%= dir.src %>/index.jade"

    # https://github.com/gruntjs/grunt-contrib-sass
        sass:
            options:
                unixNewlines: true
                precision: 5
            dev:
                options:
                    sourcemap: "auto"
                    style: "expanded"
                src: "<%= dir.src %>/styles/main-dev.scss"
                dest: "<%= dir.dist %>/main.css"
            pub:
                options:
                    sourcemap: "none"
                    style: "compressed"
                src: "<%= dir.src %>/styles/main-dev.scss"
                dest: "<%= dir.dist %>/main.css"

    # https://github.com/jmreidy/grunt-browserify
        browserify:
            options:
                transform: ["coffeeify", "jadeify"]
            dev:
                options:
                    browserifyOptions:
                        extensions: [".js", ".coffee", ".jade"]
                        fullPaths: false
                        debug: true
                files:
                    "<%= dir.dist %>/app.js": ["<%= dir.src %>/scripts/**/*.js", "<%= dir.src %>/scripts/**/*.coffee"]
            pub:
                options:
                    browserifyOptions:
                        extensions: [".js", ".coffee", ".jade"]
                        fullPaths: false
                        debug: false
                files:
                    "<%= dir.tmp %>/app.js": ["<%= dir.src %>/scripts/**/*.js", "<%= dir.src %>/scripts/**/*.coffee"]

    # https://github.com/gruntjs/grunt-contrib-uglify
    # https://github.com/shinnn/uglify-save-license
    # http://qiita.com/shinnn/items/57327006390f2181f550
        uglify:
            options:
                preserveComments: require "uglify-save-license"
                sourceMap: false
            pub:
                files:
                    "<%= path.dist %>/app.js": "<%= path.dist %>/app.js"

    # https://github.com/mllrsohn/grunt-node-webkit-builder
    # https://github.com/mllrsohn/node-webkit-builder
        nodewebkit:
            options:
                platforms: ["win"]
                buildDir: "<%= dir.build %>"
                cacheDir: "<%= dir.nw %>"
            src: nwSrc()

    # https://github.com/gruntjs/grunt-contrib-watch
        watch:
            copy_images:
                files: ["<%= copy.images.src %>"]
                tasks: ["newer:copy:images"]
            copy_fonts:
                files: ["<%= copy.fonts.src %>"]
                tasks: ["newer:copy:fonts"]
            jade:
                files: ["<%= dir.src %>/index.jade"]
                tasks: ["jade:dev"]
            sass:
                files: ["<%= dir.src %>/styles/**/*.scss"]
                tasks: ["sass:dev"]
            browserify:
                files: ["<%= dir.src %>/scripts/**/*.{js,coffee,json}"]
                tasks: ["browserify:dev"]

        # Gruntプラグインをまとめて読み込む
        # https://github.com/sindresorhus/load-grunt-tasks
        require("load-grunt-tasks") grunt

    grunt.registerTask "default", ["clean:dev", "copy", "jade:dev", "sass:dev", "browserify:dev", "watch"]
    grunt.registerTask "build", ["clean:pub", "copy", "jade:pub", "sass:pub", "browserify:pub", "uglify:pub", "nodewebkit"]
