"use strict"

path = require "path"
loadConfig = (file) -> require path.resolve file

module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  require("time-grunt") grunt

  grunt.initConfig
    context:
      dir:
        src: "src"
        test: "test"
        tmp: ".tmp"
        compiled: ".tmp/compiled"
        dist: "web"
        vendor: "bower_components"
    fileDeps: loadConfig "file-dependency.conf.coffee"
    clean:
      intermediate:
        files: [
          dot: true
          src: [
            "<%= context.dir.tmp %>"
          ]
        ]
      target:
        files: [
          dot: true
          src: [
            "<%= context.dir.dist %>"
          ]
        ]
    haml:
      compile:
        files: [{
          expand: true
          cwd: "<%= context.dir.src %>"
          src: "**/*.haml"
          dest: "<%= context.dir.compiled %>"
          ext: ".html"
        }]
    coffee:
      compile:
        options:
          sourceMap: true
          sourceRoot: ""
        files: [{
          expand: true
          cwd: "<%= context.dir.src %>"
          src: "**/*.coffee"
          dest: "<%= context.dir.compiled %>"
          ext: ".js"
        }]
    copy:
      templates:
        files: [{
          expand: true
          cwd: "<%= context.dir.compiled %>"
          src: ["**/*.html"]
          dest: "<%= context.dir.dist %>"
        }]
      scripts:
        files: [{
          expand: true
          cwd: "<%= context.dir.compiled %>"
          src: ["**/*.{js,map}"]
          dest: "<%= context.dir.dist %>"
        }]
      styles:
        files: [{
          expand: true
          cwd: "<%= context.dir.src %>"
          src: ["**/*.css"]
          dest: "<%= context.dir.dist %>"
        }]
    symlink:
      vendor:
        src: "<%= context.dir.vendor %>"
        dest: "<%= context.dir.dist %>/vendor"
    karma:
      unit:
        configFile: "karma.conf.coffee"
        singleRun: true
    coffeelint:
      options:
        configFile: "coffeelint.json"
      target:
        files:
          src: [
            "Gruntfile.coffee"
            "<%= context.dir.src %>/**/*.coffee"
            "<%= context.dir.test %>/**/*.coffee"
          ]
    makeMainJs:
      target:
        dest: "<%= context.dir.dist %>/scripts/<%= fileDeps.main.name %>"
        main: "<%= fileDeps.main.deps %>"
    makePriority:
      scripts:
        options:
          baseUrl: "<%= context.dir.dist %>"
        deps: "<%= fileDeps.main.deps.shim %>"
        done: (priority) ->
          # priority には js ファイルのリストが入っている。
    watch:
      options:
        spawn: false
      haml:
        files: [
          "<%= context.dir.src %>/**/*.haml"
        ]
        tasks: [
          "newer:haml:compile"
          "newer:copy:templates"
        ]
      coffee:
        files: [
          "<%= context.dir.src %>/**/*.coffee"
        ]
        tasks: [
          "newer:coffee:compile"
          "newer:copy:scripts"
        ]
      styles:
        files: [
          "<%= context.dir.src %>/**/*.css"
        ]
        tasks: [
          "newer:copy:styles"
        ]
      coffeeTest:
        files: [
          "<%= context.dir.src %>/**/*.coffee"
          "<%= context.dir.test %>/**/*.coffee"
          "karma.conf.coffee"
        ]
        tasks: [
          "test"
        ]

# tasks for build
  grunt.registerTask "build", [
    "doBuild"
    "clean:intermediate"
  ]

  grunt.registerTask "watchBuild", [
    "doBuild"
    "watch"
  ]

  grunt.registerTask "doBuild", [
    "clean:intermediate"
    "clean:target"
    "haml:compile"
    "copy:templates"
    "coffee:compile"
    "copy:scripts"
    "makeMainJs:target"
    "copy:styles"
    "symlink:vendor"
  ]

# tasks for test
  grunt.registerTask "test", ["doTest"]

  grunt.registerTask "watchTest", [
    "doTest",
    "watch:coffeeTest"
  ]

  grunt.registerTask "doTest", [
    "cs"
    "karma:unit:start"
  ]

  grunt.registerTask "cs", [
    "coffeelint:target"
  ]
