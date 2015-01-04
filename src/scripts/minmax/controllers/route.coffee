"use strict"

do (moduleName = "amo.minmax.controllers") ->
  angular.module moduleName
  .config [
    "$routeProvider"
    "amo.minmax.module.translator.transResolverProvider"
    ($routeProvider, transResolverProvider) ->
      $routeProvider
      .when "/",
        templateUrl: "templates/minmax.html"
        controller: "#{moduleName}.minmax"
        resolve:
          trans: transResolverProvider.getResolver()
  ]
