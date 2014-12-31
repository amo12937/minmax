"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Com.DoubleChecker", [
    "#{moduleName}.Com.Base"
    "#{moduleName}.Com.AlphaBeta"
    "#{moduleName}.Com"
    (ComBase, AlphaBeta, MinMax) ->
      (name, boardMaster, maxDepth = 7, delay = 0) ->
        ab = AlphaBeta name, boardMaster, maxDepth, delay
        mm = MinMax name, boardMaster, maxDepth, delay
        self = ComBase name, boardMaster, maxDepth, delay
        self.getChosen = (depth) ->
          abPos = ab.getChosen depth
          mmPos = mm.getChosen depth
          unless abPos[0] is mmPos[0] and abPos[1] is mmPos[1]
            console.log "abPos = (#{abPos}), mmPos = (#{mmPos})"
          return abPos
        return self
  ]
