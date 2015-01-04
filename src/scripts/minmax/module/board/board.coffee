"use strict"

do (moduleName = "amo.minmax.module.board") ->
  _white = 0 # 後手
  _black = 1 # 先手
  getOther = (t) -> 1 - t

  angular.module moduleName, ["ng"]
  .factory "#{moduleName}.RandomScoreCreator", ->
    (min, max) -> -> Math.floor(Math.random() * (max - min + 1)) + min

  .factory "#{moduleName}.Board", [
    "#{moduleName}.RandomScoreCreator"
    (RandomScoreCreator) ->
      (p1, p2, rank = 7, min = -10, max = 10) ->
        createScore = RandomScoreCreator min, max

        l = [0 .. rank - 1]
        isInside = (p) -> 0 <= p[_white] < rank and 0 <= p[_black] < rank
        scoreTable = do ->
          t =  (({score: createScore(i, j), pos: [i, j], selectable: true} for j in l) for i in l)
          (p) ->
            return {score: outside, pos: [p[_white], p[_black]], selectable: false} unless isInside p
            return t[p[_white]][p[_black]]
#          self =
#            get: (p) ->
#              return {score: outside, pos: [p[_white], p[_black]], selectable: false} unless isInside p
#              return t[p[_white]][p[_black]]
#        scoreTable = do (b = _black, w = _white) ->
#          t = (({score: createScore(i, j), pos: [i, j], selectable: true} for j in l) for i in l)
#          self =
#            isInside: (p) -> 0 <= p[_white] < rank and 0 <= p[_black] < rank
#            get: (p) ->
#              return t[p[w]][p[b]].score if self.isInside p
#            used: (p) ->
#              return false unless self.isInside p
#              return t[p[w]][p[b]][0]
#            use: (p) ->
#              return false unless self.isInside p
#              return false if self.used p
#              t[p[w]][p[b]][0] = true
#              return true
#            unuse: (p) ->
#              return false unless self.used p
#              t[p[w]][p[b]][0] = false
#              return false

        players = do (p = [], p1, p2) ->
          p[_black] = p1
          p[_white] = p2
          return p

        turn = _black
        score = [0, 0]
        pos = []
        stack = []

        self =
          const:
            rank: -> rank
            TURN:
              BLACK: _black
              WHITE: _white
          current:
            player: ->
              return players[turn]
            turn: (t) ->
              return turn if t is undefined
              return turn is t
            value: (t) ->
              return score[t] - score[getOther t]
            score: (t) ->
              return score[t]
            getSelectableList: ->
              if pos[turn] is undefined
                return ([i // rank, i % rank] for i in [0 .. rank * rank - 1])
              if turn is _black
                return ([pos[_white], i] for i in l when scoreTable([pos[_white], i]).selectable)
              else
                return ([i, pos[_black]] for i in l when scoreTable([i, pos[_black]]).selectable)
                
          get: (p) -> scoreTable(p).score

          used: (p) -> not scoreTable(p).selectable

          selectable: (p) ->
            return false unless isInside p
            t = getOther turn
            return true if pos[turn] is undefined
            return false unless p[t] is pos[t]
            return scoreTable(p).selectable

          select: (p) ->
            return false unless self.selectable p
            s = scoreTable p
            oldPos = pos
            pos = s.pos
            score[turn] += s.score
            s.selectable = false
            t = turn
            turn = getOther turn

            stack.push ->
              turn = t
              s.selectable = true
              score[turn] -= s.score
              pos = oldPos
              return

            return true

          undo: (p) -> stack.pop()?()

          isFinished: ->
            return false if pos[turn] is undefined
            p = [pos[_white], pos[_black]]
            for i in l
              p[turn] = i
              if scoreTable(p).selectable
                return false
            return true
  ]

