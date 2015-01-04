"use strict"

module.exports =
  vendor:
    name: "vendor.js"
    ext: ".js"
    src: [
      "angular/angular.min.js"
      "angular-route/angular-route.min.js"
      "angular.amo.module.translator/dist/js/translator.min.js"
      "angular.amo.module.state_machine/dist/js/state_machine.min.js"
      "angular.amo.module.game.game/dist/js/game.min.js"
      "angular.amo.module.game.player/dist/js/player.min.js"
    ]
  require:
    name: "require.js"
    src: "requirejs"
  main:
    name: "main.js"
    deps:
      baseUrl: "scripts"
      shim:
        "minmax/module/translator/apis/getRule": ["minmax/module/translator/translator"]
        "minmax/module/translator/transResolver": ["minmax/module/translator/translator", "minmax/module/translator/apis/getRule"]
        "controllers/minmax": [
          "minmax/module/board/board"
        ]
        "controllers/route": [
          "controllers/minmax"
          "minmax/module/translator/transResolver"
        ]
        "app": ["controllers/minmax", "controllers/route", "modules/ngLoadScript/ngLoadScript"]
        "bootstrap": ["app"]
      deps: ["bootstrap"]
  test:
    files: [
      "<%= context.dir.vendor %>/angular/angular.js"
      "<%= context.dir.vendor %>/angular-route/angular-route.js"
      "<%= context.dir.vendor %>/angular-mocks/angular-mocks.js"
      "<%= context.dir.vendor %>/angular.amo.module.translator/dist/js/translator.min.js"
      "<%= context.dir.vendor %>/angular.amo.module.state_machine/dist/js/state_machine.min.js"
      "<%= context.dir.vendor %>/angular.amo.module.game.game/dist/js/game.min.js"
      "<%= context.dir.vendor %>/angular.amo.module.game.player/dist/js/player.min.js"
      "<%= context.dir.src %>/scripts/minmax/module/translator/translator.coffee"
      "<%= context.dir.src %>/scripts/**/*.coffee"
      "<%= context.dir.test %>/spec/**/*.coffee"
    ]
