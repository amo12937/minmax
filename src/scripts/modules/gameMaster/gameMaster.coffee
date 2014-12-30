"use strict"

do (moduleName = "amo.minmax.GameMaster") ->
  angular.module moduleName, ["ng"]

  .factory "#{moduleName}.GameMasterFsm", ->
    (action) ->
      currentState = null
      changing = false
      setState = (state) ->
        return if changing
        changing = true
        currentState?.Exit?()
        currentState = state
        state?.Entry?()
        changing = false

      defaultAction = ->
      class DefaultState
        Entry: defaultAction
        Exit: defaultAction
        start: defaultAction
        finish: defaultAction
        endGame: defaultAction
        stop: -> setState STOPPED
        started: -> false
        done: -> false
        stopped: -> false

      INIT = new class extends DefaultState
        start: -> setState PLAYING
      PLAYING = new class extends DefaultState
        Entry: -> action.startPlaying()
        Exit: -> action.finishPlaying()
        finish: -> setState PLAYING
        endGame: -> setState DONE
        started: -> true
      DONE = new class extends DefaultState
        Entry: -> action.endGame()
        stop: defaultAction
        done: -> true
      STOPPED = new class extends DefaultState
        Entry: -> action.stop()
        stop: defaultAction
        stopped: -> true

      currentState = INIT

      self = -> currentState
      self.changing = -> changing
      return self

  .factory "#{moduleName}.GameMaster", [
    "$timeout"
    "#{moduleName}.GameMasterFsm"
    ($timeout, Fsm) ->
      makeRing = (players) ->
        q = players[players.length - 1]
        for p in players
          do (r = p) ->
            q.succ = -> r
          q = p
        return
          
      nextPlayer = (player) ->
        return player.next?() or player.succ()

      (delegate, players) ->
        makeRing players
        current = players[0]
        fsm = Fsm
          startPlaying: ->
            $timeout ->
              console.log "turn = #{current.id()}"
              current.play (ended) ->
                if ended
                  fsm().endGame()
                else
                  fsm().finish()
          finishPlaying: ->
            current = nextPlayer current
          endGame: ->
            delegate.endGame?()
          stop: ->
            delegate.stop?()

        self =
          start: ->
            fsm().start()
          current: -> current
          stop: ->
            fsm?().stop()
          started: ->
            fsm?().started()
          done: ->
            fsm?().done()
          stopped: ->
            fsm?().stopped()
  ]

