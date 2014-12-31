"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Com.Base", [
    "$timeout"
    "#{moduleName}.PlayerBase"
    ($timeout, PlayerBase) ->
      (name, boardMaster, maxDepth = 7, delay = 0) ->
        self = PlayerBase name
        self.play = (callback) ->
          $timeout ->
            pos = self.getChosen maxDepth
            boardMaster.select pos
            callback boardMaster.isFinished()
          , delay
        return self
  ]
