"use strict"

do (moduleName = "amo.minmax.BoardMaster") ->
  _v = 0
  _h = 1
  _nextTurn = (turn) -> 1 - turn
  _unselectable = "**"

  angular.module moduleName, ["ng"]

  .factory "#{moduleName}.RandomScoreCreator", ->
    (min, max) -> -> Math.floor(Math.random() * (max - min + 1)) + min

  .factory "#{moduleName}.Board", ->
    (rank, createScore, outside) ->
      l = [0 .. rank - 1]
      b = ((createScore i, j for j in l) for i in l)
      self =
        rank: -> rank
        isInside: (p) -> 0 <= p[_v] < rank and 0 <= p[_h] < rank
        get: (p) ->
          return b[p[_v]][p[_h]] if self.isInside p
          return outside
        set: (p, s) ->
          if self.isInside p
            b[p[_v]][p[_h]] = s

  .factory "#{moduleName}.BoardMaster", [
    "#{moduleName}.RandomScoreCreator"
    "#{moduleName}.Board"
    (RandomScoreCreator, Board) ->
      BoardMaster = (board, first = _v) ->
        turn = if first isnt _h then _v else _h
        score = [0, 0]
        pos = []
        stack = []
      
        self =
          current:
            board:
              get: (p) -> board.get p
              selectable: (p) -> board.get(p) isnt _unselectable
            turn: -> turn
            score: -> [score[_v], score[_h]]
            position: -> [pos[_v], pos[_h]]
      
          selectable: (n) ->
            return false unless 0 <= n < board.rank()
            return true if pos[_nextTurn turn] is undefined
            p = [pos[_v], pos[_h]]
            p[turn] = n
            return board.get(p) isnt _unselectable
      
          select: (n) ->
            return false unless self.selectable n
            t = turn
            m = pos[t]
            pos[t] = n
            if pos[_nextTurn t] is undefined
              s = 0
            else
              s = board.get pos
            score[t] += s
            board.set pos, _unselectable
            turn = _nextTurn t
      
            stack.push ->
              turn = t
              board.set pos, s
              score[t] -= s
              pos[t] = m
      
            return true
      
          undo: -> stack.pop()?()

          isFinished: ->
            return false for n in [0 .. board.rank() - 1] when self.selectable n
            return true
      BoardMaster.TURN =
        H: _h
        V: _v
      return BoardMaster
  ]
