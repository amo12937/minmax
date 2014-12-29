"use strict"

do (moduleName = "amo.minmax.BoardMaster") ->
  _v = 0
  _h = 1
  _nextTurn = (turn) -> 1 - turn
  _used = "**"

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

  .factory "#{moduleName}.BoardMaster", ->
    BoardMaster = (board, first = _h) ->
      turn = if first isnt _v then _h else _v
      score = [0, 0]
      pos = []
      stack = []
    
      self =
        const:
          TURN:
            H: _h
            V: _v
        current:
          turn: -> turn
          score: (turn) ->
            return [score[_v], score[_h]] if turn is undefined
            return score[turn]
          position: (p) ->
            return [pos[_v], pos[_h]] if p is undefined
            return p[_v] is pos[_v] and p[_h] is pos[_v]

        get: (p) -> board.get p

        used: (p) -> board.get(p) is _used
    
        selectable: (p) ->
          return false unless board.isInside p
          t = _nextTurn turn
          return true if pos[t] is undefined
          return false unless p[t] is pos[t]
          return board.get(p) isnt _used
    
        select: (p) ->
          return false unless self.selectable p
          oldPos = pos
          pos = [p[_v], p[_h]]
          s = board.get pos
          score[turn] += s
          board.set pos, _used
          t = turn
          turn = _nextTurn t
    
          stack.push ->
            turn = t
            board.set pos, s
            score[turn] -= s
            pos = oldPos
    
          return true
    
        undo: -> stack.pop()?()

        isFinished: ->
          return false if pos[turn] is undefined
          p = self.current.position()
          for n in [0 .. board.rank() - 1]
            p[turn] = n
            if self.selectable p
              return false
          return true
    BoardMaster.TURN =
      H: _h
      V: _v
    return BoardMaster
