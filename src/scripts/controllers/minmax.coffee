"use strict"

do (moduleName = "amo.minmax.controllers") ->
  angular.module moduleName, ["ng"]
  .controller "#{moduleName}.minmax", [
    "$scope"
    ($scope) ->
      $scope.hoge = "hello world"
  ]
