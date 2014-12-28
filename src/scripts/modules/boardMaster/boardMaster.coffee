"use strict"

do (moduleName = "amo.minmax.BoardMaster") ->
  angular.module(moduleName, ["ng"])
  .factory "#{moduleName}.RandomScoreCreator", ->
    (min, max) -> -> Math.floor(Math.random() * (max - min + 1)) + min
  .factory "#{moduleName}.Board", ->
    (rank, createScore, defaultScore = 0) ->
      l = [1 .. rank]
      b = (createScore i, j for j in l) for i in l
      get: (p) -> b[p[v]]?[p[h]] or defaultScore
      set: (p, s) -> b[p[v]][p[h]] = s if b[p[v]]?[p[h]]
  .factory "#{moduleName}.BoardMaster", [
    "#{moduleName}.RandomScoreCreator"
    "#{moduleName}.Board"
    (RandomScoreCreator, Board) ->
      v = 0
      h = 1
      nextTurn = (turn) -> 1 - turn
      unselectable = "**"
      
      return (rank, min, max, first = v) ->
        board = Board rank, RandomScoreCreator(min, max), 0
        turn = if first isnt h then v else h
        score = [0, 0]
        pos = []
        stack = []
      
        self =
          const:
            TURN:
              H: h
              V: v
      
          current:
            board: ->
              get: (p) -> board.get p
            turn: -> turn
            score: -> [score[v], score[h]]
            position: -> [pos[v], pos[h]]
      
          selectable: (n) ->
            return false unless 0 <= n < rank
            p = [pos[v], pos[h]]
            p[turn] = n
            return board.get(p) isnt unselectable
      
          select: (n) ->
            return false unless self.selectable n
            t = turn
            m = pos[t]
            pos[t] = n
            s = board.get nextPos
            score[t] += s
            board.set pos, unselectable
            turn = nextTurn t
      
            stack.push ->
              turn = t
              board.set pos, s
              score[t] -= s
              pos[t] = m
      
            return true
      
          undo: -> stack.pop()?()
  ]
