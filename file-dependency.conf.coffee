"use strict"

module.exports =
  test:
    files: [
      "<%= context.dir.vendor %>/angular/angular.js"
      "<%= context.dir.vendor %>/angular-mocks/angular-mocks.js"
      "<%= context.dir.src %>/scripts/modules/player/player.coffee"
      "<%= context.dir.src %>/scripts/**/*.coffee"
      "<%= context.dir.test %>/spec/**/*.coffee"
    ]
