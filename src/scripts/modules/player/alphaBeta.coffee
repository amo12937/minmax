"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Com.AlphaBeta", [
    "#{moduleName}.Com.Base"
    (ComBase) ->
      (name, boardMaster, maxDepth = 7, delay = 0) ->
        l = [0 .. boardMaster.const.rank() - 1]

        choice = (depth, a, b) ->
          return 0 if depth <= 0
          pos = boardMaster.current.position()         # 現在の位置
          turn = boardMaster.current.turn()            # 自分のターン
          if boardMaster.isFinished()
            if boardMaster.current.result turn
              return Infinity
            else
              return -Infinity

          for i in l
            pos[turn] = i                              # 位置を更新
            continue unless boardMaster.selectable pos # その位置が選択不可なら次
            boardMaster.select pos                     # 選択
            s = boardMaster.current.score turn         # 現在の得点が更新される
            t = s - choice depth - 1, s - b, s - a     # 相手が最善手を選んだ場合の評価値
            boardMaster.undo()
            if t > a
              a = t
            if a >= b
              return a                                 # ここで返ってくるのは、評価値 a が b つまりひとつ上の S - A を上回った場合(a >= S - A)。ひとつ上では、T = S - a として、 T > A が評価されるが、a >= S - A より T = S - a <= A だから、T は必ず A を下回っているので、この T によって A が上書きされることはない。for 文を回して次の評価値 t2 を調べても、t より小さければ採択されず、大きければやはり上で採択されないので、これ以上調べても意味がない。ゆえに、ここで返しても問題無い。
          return a

        choiceFirst = (depth) ->
          score = -Infinity
          result = [0, 0]
          turn = boardMaster.current.turn()
          for i in l
            for j in l
              pos = [i, j]
              boardMaster.select pos
              s = boardMaster.current.score turn
              t = s - choice depth - 1, -Infinity, Infinity
              boardMaster.undo()
              if t >= score
                score = t
                result = pos
          return result

        choiceNext = (depth) ->
          return [0, 0] if depth <= 0
          return [0, 0] if boardMaster.isFinished()
          pos = boardMaster.current.position()
          turn = boardMaster.current.turn()
          score = -Infinity
          result = 0
          for i in l
            pos[turn] = i
            continue unless boardMaster.selectable pos
            boardMaster.select pos
            s = boardMaster.current.score turn
            t = s - choice depth - 1, -Infinity, Infinity
            boardMaster.undo()
            if t >= score
              score = t
              result = i
          pos[turn] = result
          return pos
          
        self = ComBase name, boardMaster, maxDepth, delay
        self.getChosen = (depth) ->
          if boardMaster.current.isFirst()
            return choiceFirst maxDepth
          else
            return choiceNext maxDepth
        return self
  ]
