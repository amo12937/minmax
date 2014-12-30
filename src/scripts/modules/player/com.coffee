"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Com", [
    "$timeout"
    ($timeout) ->
      (boardMaster, maxDepth = 7, delay = 0) ->
        l = [0 .. boardMaster.const.rank() - 1]
        choice = (depth) ->
          return [0, [0, 0]] if depth <= 0
          return [0, [0, 0]] if boardMaster.isFinished()
          pos = boardMaster.current.position()
          turn = boardMaster.current.turn()
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
          pos[turn] = result
          return [score, pos]
        choiceFirst = (depth) ->
          turn = boardMaster.current.turn()
          score = -Infinity
          result = 0
          for i in l
            for j in l
              pos = [i, j]
              boardMaster.select pos
              s = boardMaster.current.score turn
              [s2, _] = choice depth - 1
              s -= s2
              boardMaster.undo()
              if s > score
                score = s
                result = pos
          return [score, result]
          
        play: (callback) ->
          $timeout ->
            if boardMaster.current.isFirst()
              [_, pos] = choiceFirst maxDepth
            else
              [_, pos] = choice maxDepth
            boardMaster.select pos
            callback boardMaster.isFinished()
          , delay
  ]
