"use strict"

do (moduleName = "amo.minmax.module.Translator") ->
  angular.module moduleName
  .factory "#{moduleName}.api.GetRule", [
    "$http"
    "#{moduleName}.config"
    ($http, config) ->
      ->
        self =
          getPath: (name, ext = config.resourceExt) -> "#{config.resourceDir}#{name}#{ext}"
          request: (name, ext) ->
            $http.get self.getPath name, ext
  ]
