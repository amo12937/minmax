"use strict"

do (moduleName = "amo.minmax.module.translator") ->
  angular.module moduleName, ["ng", "amo.module.translator"]
  .value "#{moduleName}.config",
    resourceDir: "res/minmax/translator/"
    resourceExt: ".json"
    loader:
      trans:
        rules: [
          {key: "en", displayName: "English"}
          {key: "jp", displayName: "日本語"}
        ]
        defaultRule: "jp"
