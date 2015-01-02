"use strict"

describe "amo.minmax.Player モジュールの仕様", ->
  moduleName = "amo.minmax.Player"

  beforeEach module moduleName

  describe "Man の仕様", ->
    Man = null
    name = "man"
    beforeEach ->
      inject ["#{moduleName}.Man", (_Man) ->
        Man = _Man
      ]

    it "boardMaster を受け取り、choice, play 関数を持つオブジェクトを返す", ->
      man = Man name, {}
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
        man = Man name, boardMaster
        inject ["$rootScope", (_$rootScope) ->
          $rootScope = _$rootScope
        ]

      it "play の前に choice を呼んでも、selectable は呼ばれない", ->
        choice = [1, 2]
        man.choice choice
        expect(boardMaster.selectable).not.toHaveBeenCalled()

      it "play の後に choice を呼び、selectable なら promise が解決される", (done) ->
        choice = [1, 2]
        boardMaster.selectable.and.returnValue true

        expected = {}
        boardMaster.isFinished.and.returnValue expected

        promise = man.play()
        expect(boardMaster.selectable).not.toHaveBeenCalled()
        expect(boardMaster.select).not.toHaveBeenCalled()
        expect(boardMaster.isFinished).not.toHaveBeenCalled()

        man.choice choice
        expect(boardMaster.selectable).toHaveBeenCalledWith choice
        expect(boardMaster.select).toHaveBeenCalledWith choice
        expect(boardMaster.isFinished).toHaveBeenCalled()
        promise.then (actual) ->
          expect(actual).toBe expected
          done()
        $rootScope.$digest()

      it "play の後に choice を呼んでも、selectable でなければ promise は解決しない", ->
        choice = [1, 2]
        boardMaster.selectable.and.returnValue false

        counter = 0
        man.play().then -> counter++
        man.choice choice
        expect(boardMaster.selectable).toHaveBeenCalledWith choice
        expect(boardMaster.select).not.toHaveBeenCalled()
        expect(boardMaster.isFinished).not.toHaveBeenCalled()
        $rootScope.$digest()
        expect(counter).toBe 0

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
        counters = [0, 0, 0]
        boardMaster.selectable.and.returnValue true

        man.play().then -> counters[0]++
        man.play().then -> counters[1]++
        man.play().then -> counters[2]++

        man.choice [1, 2]
        $rootScope.$digest()
        expect(counters).toEqual [0, 0, 1]

