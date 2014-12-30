"use strict"

do (moduleName = "amo.minmax.module.Translator") ->
  translatorModuleName = "amo.module.Translator"
  angular.module moduleName, ["ng", translatorModuleName]
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
