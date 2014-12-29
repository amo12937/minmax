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
        finishP1: defaultAction
        finishP2: defaultAction
        end: defaultAction
        stop: -> setState STOPPED
        started: -> false
        done: -> false
        stopped: -> false

      INIT = new class extends DefaultState
        start: -> setState TURN_P1
      TURN_P1 = new class extends DefaultState
        Entry: -> action.playP1()
        finishP1: -> setState TURN_P2
        end: -> setState DONE
        started: -> true
      TURN_P2 = new class extends DefaultState
        Entry: -> action.playP2()
        finishP2: -> setState TURN_P1
        end: -> setState DONE
        started: -> true
      DONE = new class extends DefaultState
        Entry: -> action.end()
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
      (delegate) ->
        fsm = null
        Action = (p1, p2) ->
          playP1: ->
            $timeout ->
              console.log "turn = p1"
              p1.play (ended) ->
                if ended
                  fsm().end()
                else
                  fsm().finishP1()
                return
          playP2: ->
            $timeout ->
              console.log "turn = p2"
              p2.play (ended) ->
                if ended
                  fsm().end()
                else
                  fsm().finishP2()
                return
          end: ->
            delegate.end?()
          stop: ->
            delegate.stop?()

        self =
          start: (p1, p2) ->
            self.stop()
            fsm = Fsm Action p1, p2
            fsm().start()
          stop: ->
            fsm?().stop()
          started: ->
            fsm?().started()
          done: ->
            fsm?().done()
          stopped: ->
            fsm?().stopped()
  ]

