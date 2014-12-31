"use strict"

do (ng = angular) ->
  ng.module "ngLoadScript", []

  .directive "script", ->
    restrict: "E"
    scope: false
    link: (scope, elm, attr) ->
      return unless attr.type is "text/javascript-lazy"
      code = elm.text()
      f = new Function code
      f()
