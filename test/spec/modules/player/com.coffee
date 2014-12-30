"use strict"

describe "amo.minmax.Player の仕様", ->
  moduleName = "amo.minmax.Player"

  beforeEach module moduleName

  describe "Com の仕様", ->
    Com = null
    beforeEach ->
      inject ["#{moduleName}.Com", (_Com) ->
        Com = _Com
      ]

    it "boardMaster を受け取り、play 関数を持つオブジェクトを返す", ->
      com = Com
        const:
          rank: -> 7
      expect(com.play).toBeDefined()

    describe "com オブジェクトの仕様", ->
      boardMaster = null
      $timeout = null

      beforeEach ->
        boardMaster =
          current:
            position: jasmine.createSpy "current.position"
            turn: jasmine.createSpy "current.turn"
            score: jasmine.createSpy "current.score"
            isFirst: jasmine.createSpy "current.isFirst"
          selectable: jasmine.createSpy "selectable"
          select: jasmine.createSpy "select"
          undo: jasmine.createSpy "undo"
          isFinished: jasmine.createSpy "isFinished"
        inject ["$timeout", (_$timeout) ->
          $timeout = _$timeout
        ]

      it "play は $timeout に実際の play を予約する", ->

