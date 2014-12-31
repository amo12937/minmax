"use strict"

module.exports =
  vendor:
    name: "vendor.js"
    ext: ".js"
    src: [
      "angular/angular.min.js"
      "angular-route/angular-route.min.js"
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
        "modules/player/alphaBeta": ["modules/player/player"]
        "minmax/translator/translator": ["modules/translator/translatorCollection"]
        "minmax/translator/apis/getRule": ["minmax/translator/translator"]
        "minmax/translator/transResolver": ["minmax/translator/translator", "minmax/translator/apis/getRule"]
        "controllers/minmax": [
          "modules/boardMaster/boardMaster"
          "modules/gameMaster/gameMaster"
          "modules/player/man"
          "modules/player/com"
          "modules/player/alphaBeta"
        ]
        "controllers/route": [
          "controllers/minmax"
          "minmax/translator/transResolver"
        ]
        "app": ["controllers/minmax", "controllers/route"]
        "bootstrap": ["app"]
      deps: ["bootstrap"]
  test:
    files: [
      "<%= context.dir.vendor %>/angular/angular.js"
      "<%= context.dir.vendor %>/angular-route/angular-route.js"
      "<%= context.dir.vendor %>/angular-mocks/angular-mocks.js"
      "<%= context.dir.src %>/scripts/modules/player/player.coffee"
      "<%= context.dir.src %>/scripts/minmax/translator/translator.coffee"
      "<%= context.dir.src %>/scripts/**/*.coffee"
      "<%= context.dir.test %>/spec/**/*.coffee"
    ]
