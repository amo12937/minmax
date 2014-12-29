"use strict"

describe "amo.minmax.BoardMaster モジュールの仕様", ->
  moduleName = "amo.minmax.BoardMaster"

  beforeEach module moduleName

  describe "RandomScoreCreator の仕様", ->
    min = -10
    max = 10
    createScore = null

    beforeEach ->
      inject ["#{moduleName}.RandomScoreCreator", (RandomScoreCreator) ->
        createScore = RandomScoreCreator min, max
      ]

    it "最小値と最大値を受け取り、その中から値を返す関数を生成する", ->
      expect(min <= createScore() <= max).toBe true

    it "生成された関数は、内部で Math.random を使用している", ->
      spyOn(Math, "random").and.callThrough()
      createScore()
      expect(Math.random).toHaveBeenCalled()
 
  describe "Board の仕様", ->
    rank = 7
    createScore = (i, j) -> 10 * i + j
    outside = "outside"
    Board = null

    beforeEach ->
      inject ["#{moduleName}.Board", (_Board) ->
        Board = _Board
      ]

    it "rank, createScore, outside を受け取り、rank x rank の行列を返す", ->
      board = Board rank, createScore, outside

      func = (p, expected) ->
        expect(board.isInside p).toBe expected isnt outside
        expect(board.get p).toBe expected

      dataProvider = [
        [[0, 0], 0]
        [[0, 6], 6]
        [[6, 0], 60]
        [[6, 6], 66]
        [[-1, 0], outside]
        [[-1, 6], outside]
        [[0, 7], outside]
        [[6, 7], outside]
        [[7, 6], outside]
        [[7, 0], outside]
        [[6, -1], outside]
        [[0, -1], outside]
      ]

      for data in dataProvider
        func.apply @, data

    it "set で値をセットできる", ->
      board = Board rank, createScore, outside
      board.set [3, 3], 1000
      expect(board.get [3, 3]).toBe 1000
      board.set [-1, -1], 1000
      expect(board.get [-1, -1]).toBe outside

  describe "BoardMaster の仕様", ->
    rank = 7
    outside = "outside"
    board = null
    BoardMaster = null
    boardMaster = null

    beforeEach ->
      inject ["#{moduleName}.Board", "#{moduleName}.BoardMaster", (Board, _BoardMaster) ->
        createScore = (i, j) -> 10 * i + j
        board = Board rank, createScore, outside
        BoardMaster = _BoardMaster
        boardMaster = BoardMaster board, BoardMaster.TURN.H
      ]

    describe "current は", ->
      it "現在の turn を与える", ->
        expect(boardMaster.current.turn()).toBe BoardMaster.TURN.H
        boardMaster.select [3, 2]
        expect(boardMaster.current.turn()).toBe BoardMaster.TURN.V

      it "現在の score を与える", ->
        expect(boardMaster.current.score()).toEqual [0, 0]
        boardMaster.select [3, 2]
        expect(boardMaster.current.score()).toEqual [0, 32]
        boardMaster.select [6, 2]
        expect(boardMaster.current.score()).toEqual [62, 32]
        boardMaster.select [6, 1]
        expect(boardMaster.current.score()).toEqual [62, 93]

      it "現在の position を与える", ->
        expect(boardMaster.current.position()).toEqual [undefined, undefined]
        boardMaster.select [1, 4]
        expect(boardMaster.current.position()).toEqual [1, 4]
        boardMaster.select [2, 4]
        expect(boardMaster.current.position()).toEqual [2, 4]
        boardMaster.select [2, 0]
        expect(boardMaster.current.position()).toEqual [2, 0]

    describe "get は", ->
      it "位置を受け取ってスコアを返す", ->
        p = [1, 1]
        expect(boardMaster.get p).toBe 11
        boardMaster.select p
        expect(boardMaster.get p).not.toBe 11

    describe "used は", ->
      it "その位置のスコアが使われたかどうかを返す", ->
        p = [1, 1]
        expect(boardMaster.used p).toBe false
        boardMaster.select p
        expect(boardMaster.used p).toBe true

    describe "selectable は", ->
      it "指定した位置が選択可能かを返す", ->
        expect(boardMaster.selectable [2, 5]).toBe true
        boardMaster.select [2, 5]
        expect(boardMaster.selectable [3, 5]).toBe true
        expect(boardMaster.selectable [2, 1]).toBe false
        boardMaster.select [3, 5]
        expect(boardMaster.selectable [2, 5]).toBe false
        expect(boardMaster.selectable [3, 1]).toBe true

      it "範囲外は選択できない", ->
        expect(boardMaster.selectable [0, -1]).toBe false
        expect(boardMaster.selectable [7, 0]).toBe false

    describe "select は", ->
      it "選択可能な場合、実際に選択して true を返す", ->
        expect(boardMaster.current.position()).toEqual [undefined, undefined]
        expect(boardMaster.select [5, 6]).toBe true
        expect(boardMaster.current.position()).toEqual [5, 6]
        expect(boardMaster.select [0, 6]).toBe true
        expect(boardMaster.current.position()).toEqual [0, 6]
        expect(boardMaster.current.score()).toEqual [6, 56]

    describe "undo は", ->
      it "直前の選択を取り消す", ->
        expect(boardMaster.current.position()).toEqual [undefined, undefined]
        expect(boardMaster.current.score()).toEqual [0, 0]
        boardMaster.select [2, 4]
        expect(boardMaster.current.position()).toEqual [2, 4]
        expect(boardMaster.current.score()).toEqual [0, 24]
        boardMaster.select [5, 4]
        expect(boardMaster.current.position()).toEqual [5, 4]
        expect(boardMaster.current.score()).toEqual [54, 24]
        boardMaster.select [5, 3]
        expect(boardMaster.current.position()).toEqual [5, 3]
        expect(boardMaster.current.score()).toEqual [54, 77]
        boardMaster.undo()
        expect(boardMaster.current.position()).toEqual [5, 4]
        expect(boardMaster.current.score()).toEqual [54, 24]
        boardMaster.undo()
        expect(boardMaster.current.position()).toEqual [2, 4]
        expect(boardMaster.current.score()).toEqual [0, 24]
        boardMaster.undo()
        expect(boardMaster.current.position()).toEqual [undefined, undefined]
        expect(boardMaster.current.score()).toEqual [0, 0]

    describe "isFinished は", ->
      it "一列、または一行全てが選択できなくなった時点で true を返す", ->
        expect(boardMaster.isFinished()).toBe false
        boardMaster.select [0, 0]
        boardMaster.select [1, 0]
        boardMaster.select [1, 1]
        boardMaster.select [0, 1]
        boardMaster.select [0, 2]
        boardMaster.select [1, 2]
        boardMaster.select [1, 3]
        boardMaster.select [0, 3]
        boardMaster.select [0, 4]
        boardMaster.select [1, 4]
        boardMaster.select [1, 5]
        boardMaster.select [0, 5]
        boardMaster.select [0, 6]
        expect(boardMaster.isFinished()).toBe false
        boardMaster.select [1, 6] # 1, 6
        expect(boardMaster.isFinished()).toBe true

