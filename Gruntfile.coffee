"use strict"

path = require "path"
loadConfig = (file) -> require path.resolve file

module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  require("time-grunt") grunt

  fileDeps = loadConfig "file-dependency.conf.coffee"

  grunt.initConfig
    context:
      dir:
        src: "src"
        test: "test"
        tmp: ".tmp"
        compiled: ".tmp/compiled"
        dist: "dev"
        deploy: "web"
        vendor: "bower_components"
    fileDeps: fileDeps
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
          dot: false
          src: [
            "<%= context.dir.dist %>/**/*"
          ]
        ]
      deploy:
        files: [
          dot: false
          src: [
            "<%= context.dir.deploy %>/**/*"
          ]
        ]
    haml:
      compile:
        files: [{
          expand: true
          cwd: "<%= context.dir.src %>/templates"
          src: "**/*.haml"
          dest: "<%= context.dir.compiled %>/templates"
          ext: ".html"
        }]
      dev:
        files: [{
          src: "<%= context.dir.src %>/index_DEV.haml"
          dest: "<%= context.dir.compiled %>/index.html"
        }]
      deploy:
        files: [{
          src: "<%= context.dir.src %>/index_DEPLOY.haml"
          dest: "<%= context.dir.compiled %>/index.html"
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
        }, {
          expand: true
          cwd: "<%= context.dir.src %>"
          src: ["**/*.coffee"]
          dest: "<%= context.dir.dist %>"
        }]
      styles:
        files: [{
          expand: true
          cwd: "<%= context.dir.src %>"
          src: ["**/*.css"]
          dest: "<%= context.dir.dist %>"
        }]
      vendor:
        files: [{
          expand: true
          cwd: "<%= context.dir.vendor %>"
          src: ["**/*"]
          dest: "<%= context.dir.dist %>/vendor"
        }]
      resource:
        files: [{
          expand: true
          cwd: "<%= context.dir.src %>/res"
          src: ["**/*"]
          dest: "<%= context.dir.dist %>/res"
        }]
      deploy:
        files: [{
          expand: true
          cwd: "<%= context.dir.compiled %>"
          src: ["**/*.html"]
          dest: "<%= context.dir.deploy %>"
        }, {
          expand: true
          cwd: "<%= context.dir.src %>"
          src: ["**/*.css"]
          dest: "<%= context.dir.deploy %>"
        }, {
          expand: true
          cwd: "<%= context.dir.vendor %>"
          src: ["**/*"]
          dest: "<%= context.dir.deploy %>/vendor"
        }, {
          expand: true
          cwd: "<%= context.dir.src %>/res"
          src: ["**/*"]
          dest: "<%= context.dir.deploy %>/res"
        }]
    concat:
      options:
        separator: ";"
      vendor:
        src: fileDeps.vendor.src.map (src) -> "<%= context.dir.vendor %>/#{src}"
        dest: "<%= context.dir.deploy %>/scripts/<%= fileDeps.vendor.name %>"
      scripts:
        dest: "<%= context.dir.compiled %>/scripts/scripts.js"
    uglify:
      scripts:
        src: "<%= context.dir.compiled %>/scripts/scripts.js"
        dest: "<%= context.dir.deploy %>/scripts/scripts.min.js"
    symlink:
      vendor:
        src: "<%= context.dir.vendor %>"
        dest: "<%= context.dir.dist %>/vendor"
      resource:
        src: "<%= context.dir.src %>/res"
        dest: "<%= context.dir.dist %>/res"
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
          baseUrl: "<%= context.dir.compiled %>/scripts"
        deps: "<%= fileDeps.main.deps.shim %>"
        done: (priority) ->
          grunt.config.set "concat.scripts.src", priority
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
    "haml:dev"
    "copy:templates"
    "coffee:compile"
    "copy:scripts"
    "makeMainJs:target"
    "copy:styles"
    "copy:vendor"
    "copy:resource"
  ]

  grunt.registerTask "build:deploy", [
    "clean:intermediate"
    "clean:deploy"
    "haml:compile"
    "haml:deploy"
    "coffee:compile"
    "makePriority:scripts"
    "concat:vendor"
    "concat:scripts"
    "uglify:scripts"
    "copy:deploy"
    "clean:intermediate"
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
