"use strict"

do (moduleName = "amo.minmax.Player") ->
  angular.module moduleName

  .factory "#{moduleName}.Man", [
    "$q"
    "#{moduleName}.PlayerBase"
    ($q, PlayerBase) ->
      (name, boardMaster) ->
        deferred = null
        self = PlayerBase name
        self.choice = (p) ->
          return unless deferred
          return unless boardMaster.selectable p
          deferred.resolve p
          deferred = null
        self.play = (callback) ->
          deferred = $q.defer()
          promise = deferred.promise
          promise.then (p) ->
            boardMaster.select p
            callback boardMaster.isFinished()
          return
        self
  ]

