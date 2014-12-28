"use strict"

module.exports = (config) ->
  grunt = require "grunt"
  dir = grunt.config.get "context.dir"

  config.set
    captureTimeout: 5000
    colors: true
    files: grunt.config.get "fileDeps.test.files"

    frameworks: ["jasmine"]

    exclude: []

    port: 8081

    logLevel: config.LOG_INFO

    autoWatch: false

    browsers: ["PhantomJS"]

    preprocessors: do (p = {}) ->
      p["#{dir.src}/**/*.coffee"] = "coffee"
      p["#{dir.test}/**/*.coffee"] = "coffee"
      p
    reporters: ["dots"]

    runnerPort: 9100

    singleRun: true

