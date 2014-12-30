"use strict"

module.exports =
  vendor:
    name: "vendor.js"
    ext: ".js"
    src: [
      "angular/angular.min.js"
    ]
  require:
    name: "require.js"
    src: "requirejs"
  main:
    name: "main.js"
    deps:
      baseUrl: "scripts"
      shim:
        "modules/player/man": ["modules/player/player"]
        "modules/player/com": ["modules/player/player"]
        "controllers/minmax": [
          "modules/boardMaster/boardMaster"
          "modules/gameMaster/gameMaster"
          "modules/player/man"
          "modules/player/com"
        ]
        "app": ["controllers/minmax"]
        "bootstrap": ["app"]
      deps: ["bootstrap"]
  test:
    files: [
      "<%= context.dir.vendor %>/angular/angular.js"
      "<%= context.dir.vendor %>/angular-mocks/angular-mocks.js"
      "<%= context.dir.src %>/scripts/modules/player/player.coffee"
      "<%= context.dir.src %>/scripts/**/*.coffee"
      "<%= context.dir.test %>/spec/**/*.coffee"
    ]
