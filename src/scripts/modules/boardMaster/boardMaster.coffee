"use strict"

do (moduleName = "amo.minmax.BoardMaster") ->
  _white = 0
  _black = 1
  _nextTurn = (turn) -> 1 - turn
  _used = "**"

  angular.module moduleName, ["ng"]

  .factory "#{moduleName}.RandomScoreCreator", ->
    (min, max) -> -> Math.floor(Math.random() * (max - min + 1)) + min

  .factory "#{moduleName}.Board", ->
    (rank, createScore, outside) ->
      l = [0 .. rank - 1]
      b = (([false, createScore i, j] for j in l) for i in l)
      self =
        rank: -> rank
        isInside: (p) -> 0 <= p[_white] < rank and 0 <= p[_black] < rank
        get: (p) ->
          return b[p[_white]][p[_black]][1] if self.isInside p
          return outside
        used: (p) ->
          return false unless self.isInside p
          return b[p[_white]][p[_black]][0]
        use: (p) ->
          if self.isInside p
            b[p[_white]][p[_black]][0] = true
        unuse: (p) ->
          if self.isInside p
            b[p[_white]][p[_black]][0] = false

  .factory "#{moduleName}.BoardMaster", ->
    BoardMaster = (board) ->
      turn = _black
      score = [0, 0]
      pos = []
      stack = []
    
      self =
        const:
          rank: -> board.rank()
          TURN:
            BLACK: _black
            WHITE: _white
        current:
          turn: (t) ->
            return turn if t is undefined
            return turn is t

          score: (t) ->
            return [score[_white], score[_black]] if t is undefined
            return score[t]
          position: (p) ->
            return [pos[_white], pos[_black]] if p is undefined
            return p[_white] is pos[_white] and p[_black] is pos[_white]
          isFirst: ->
            return pos[_white] is undefined and pos[_black] is undefined
          winner: (t) ->
            return score[t] > score[_nextTurn t]

        get: (p) -> board.get p

        used: (p) -> board.used(p)
    
        selectable: (p) ->
          return false unless board.isInside p
          t = _nextTurn turn
          return true if pos[t] is undefined
          return false unless p[t] is pos[t]
          return !board.used p
    
        select: (p) ->
          return false unless self.selectable p
          oldPos = pos
          pos = [p[_white], p[_black]]
          s = board.get pos
          score[turn] += s
          board.use pos
          t = turn
          turn = _nextTurn t
    
          stack.push ->
            turn = t
            board.unuse pos
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
    return BoardMaster
