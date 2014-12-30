"use strict"

describe "amo.minmax.Player モジュールの仕様", ->
  moduleName = "amo.minmax.Player"

  beforeEach module moduleName

  describe "Man の仕様", ->
    Man = null
    beforeEach ->
      inject ["#{moduleName}.Man", (_Man) ->
        Man = _Man
      ]

    it "boardMaster を受け取り、choice, play 関数を持つオブジェクトを返す", ->
      man = Man {}
      expect(man.choice).toBeDefined()
      expect(man.play).toBeDefined()

    describe "man オブジェクトの仕様", ->
      man = null
      boardMaster = null
      $rootScope = null

      beforeEach ->
        boardMaster =
          selectable: jasmine.createSpy "selectable"
          select: jasmine.createSpy "select"
          isFinished: jasmine.createSpy "isFinished"
        man = Man boardMaster
        inject ["$rootScope", (_$rootScope) ->
          $rootScope = _$rootScope
        ]

      it "play の前に choice を呼んでも、selectable は呼ばれない", ->
        choice = [1, 2]
        man.choice choice
        expect(boardMaster.selectable).not.toHaveBeenCalled()

      it "play の後に choice を呼び、selectable なら callback が呼ばれる", ->
        choice = [1, 2]
        boardMaster.selectable.and.returnValue true

        expected = {}
        boardMaster.isFinished.and.returnValue expected
        callback = jasmine.createSpy "callback"

        man.play callback
        expect(boardMaster.selectable).not.toHaveBeenCalled()
        expect(boardMaster.select).not.toHaveBeenCalled()
        expect(boardMaster.isFinished).not.toHaveBeenCalled()

        man.choice choice
        expect(boardMaster.selectable).toHaveBeenCalledWith choice
        $rootScope.$digest()
        expect(boardMaster.select).toHaveBeenCalledWith choice
        expect(boardMaster.isFinished).toHaveBeenCalled()
        expect(callback).toHaveBeenCalledWith expected

      it "play の後に choice を呼んでも、selectable でなければ callback は呼ばれない", ->
        choice = [1, 2]
        boardMaster.selectable.and.returnValue false

        callback = jasmine.createSpy "callback"

        man.play callback
        man.choice choice
        expect(boardMaster.selectable).toHaveBeenCalledWith choice
        $rootScope.$digest()
        expect(boardMaster.select).not.toHaveBeenCalled()
        expect(boardMaster.isFinished).not.toHaveBeenCalled()
        expect(callback).not.toHaveBeenCalled()

      it "play の後に choice を 複数回呼ぶと、初めの selectable なもののみ採択される", ->
        man.play ->

        boardMaster.selectable.and.returnValue false

        expect(boardMaster.selectable.calls.count()).toBe 0
        man.choice [1, 3]
        expect(boardMaster.selectable.calls.count()).toBe 1
        man.choice [2, 5]
        expect(boardMaster.selectable.calls.count()).toBe 2

        boardMaster.selectable.and.returnValue true

        man.choice [4, 0]
        expect(boardMaster.selectable.calls.count()).toBe 3
        man.choice [6, 2]
        expect(boardMaster.selectable.calls.count()).toBe 3
        man.choice [3, 3]
        expect(boardMaster.selectable.calls.count()).toBe 3

      it "play を複数回呼ぶと、最後の play に対する callback のみ呼ばれる", ->
        callbacks = [
          jasmine.createSpy("callback 0")
          jasmine.createSpy("callback 1")
          jasmine.createSpy("callback 2")
        ]
        boardMaster.selectable.and.returnValue true

        man.play callbacks[0]
        man.play callbacks[1]
        man.play callbacks[2]

        man.choice [1, 2]
        $rootScope.$digest()
        expect(callbacks[0]).not.toHaveBeenCalled()
        expect(callbacks[1]).not.toHaveBeenCalled()
        expect(callbacks[2]).toHaveBeenCalled()

