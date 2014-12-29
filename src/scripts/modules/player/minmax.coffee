"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Minmax", [
    "$timeout"
    ($timeout) ->
      (boardMaster, maxDepth = 7, delay = 0) ->
        l = [0 .. boardMaster.const.rank() - 1]
        choice = (depth) ->
          return [0, 0] if depth <= 0
          return [0, 0] if boardMaster.isFinished()
          pos = boardMaster.current.position()
          turn = boardMaster.current.turn()
          #console.log
          #  depth: depth
          #  pos: pos
          #  turn: turn
          score = -Infinity
          result = 0
          for i in l
            pos[turn] = i
            continue unless boardMaster.selectable pos
            boardMaster.select pos
            s = boardMaster.current.score turn
            [s2, _] = choice depth - 1
            s -= s2
            boardMaster.undo()
            if s > score
              score = s
              result = i
          return [score, result]
          
        play: (callback) ->
          pos = boardMaster.current.position()
          turn = boardMaster.current.turn()
          [_, result] = choice maxDepth
          pos[turn] = result
          $timeout ->
            boardMaster.select pos
            callback boardMaster.isFinished()
          , delay
  ]
