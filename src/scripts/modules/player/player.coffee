"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName, ["ng"]
  .factory "#{moduleName}.PlayerBase", ->
    idSeed = 0
    return (name) ->
      id = idSeed++
      id: -> id
      name: -> name
