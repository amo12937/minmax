"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Com.Base", [
    "$timeout"
    "$q"
    "#{moduleName}.PlayerBase"
    ($timeout, $q, PlayerBase) ->
      (name, boardMaster, maxDepth = 7, delay = 0) ->
        self = PlayerBase name
        self.play = ->
          deferred = $q.defer()
          $timeout ->
            pos = self.getChosen maxDepth
            boardMaster.select pos
            deferred.resolve boardMaster.isFinished()
          , delay
          return deferred.promise
        return self
  ]
