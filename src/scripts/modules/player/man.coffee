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
          boardMaster.select p
          deferred.resolve boardMaster.isFinished()
          deferred = null
        self.play = ->
          deferred = $q.defer()
          return deferred.promise
        return self
  ]

