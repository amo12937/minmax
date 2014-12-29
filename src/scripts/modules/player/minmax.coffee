"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Minmax", [
    "$timeout"
    ($timeout) ->
      (boardMaster) ->
        l = [0 .. boardMaster.const.rank() - 1]
        play: (callback) ->
          pos = boardMaster.current.position()
          turn = boardMaster.current.turn()
          score = -Infinity
          result = 0
          for i in l
            pos[turn] = i
            continue if boardMaster.used pos
            s = boardMaster.get pos
            if s > score
              score = s
              result = i
          pos[turn] = result
          $timeout ->
            boardMaster.select pos
            callback boardMaster.isFinished()
          , 1000
  ]
