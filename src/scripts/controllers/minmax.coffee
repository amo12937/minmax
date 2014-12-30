"use strict"

do (modulePrefix = "amo.minmax") ->
  angular.module "#{modulePrefix}.controllers", [
    "ng"
    "ngRoute"
    "#{modulePrefix}.BoardMaster"
    "#{modulePrefix}.Player"
    "#{modulePrefix}.GameMaster"
    "#{modulePrefix}.module.Translator"
]
  .controller "#{modulePrefix}.controllers.minmax", [
    "$location"
    "$route"
    "$scope"
    "#{modulePrefix}.BoardMaster.RandomScoreCreator"
    "#{modulePrefix}.BoardMaster.Board"
    "#{modulePrefix}.BoardMaster.BoardMaster"
    "#{modulePrefix}.Player.Man"
    "#{modulePrefix}.Player.Com"
    "#{modulePrefix}.GameMaster.GameMaster"
    ($location, $route, $scope, RandomScoreCreator, Board, BoardMaster, Man, Com, GameMaster) ->
      playerTypes = {"MAN", "COM"}
      toNum = (n, d) ->
        return d unless n
        return Number n

      createPlayer = (type, name, level, delay) ->
        return Com name, $scope.boardMaster, Math.max(level, 1), Math.max(delay, 0) if type is playerTypes.COM
        return Man name, $scope.boardMaster

      opts = $location.search()
      options =
        min: toNum opts.min, -10
        max: toNum opts.max, 10
        rank: toNum opts.rank, 7
        p1: opts.p1 or playerTypes.MAN
        p1_name: opts.p1_name or "you"
        p1_level: toNum opts.p1_level, 5
        p1_delay: toNum opts.p1_delay, 100
        p2: opts.p2 or playerTypes.COM
        p2_name: opts.p2_name or "com"
        p2_level: toNum opts.p2_level, 5
        p2_delay: toNum opts.p2_delay, 100

      $scope.levels = [1..9]
      $scope.p2_level = options.p2_level

      createScore = RandomScoreCreator options.min, options.max
      board = Board options.rank, createScore, "outside"
      $scope.boardMaster = boardMaster = BoardMaster board
      $scope.rankList = [0 .. options.rank - 1]

      players = {}
      players[boardMaster.const.TURN.BLACK] = createPlayer options.p1, options.p1_name, options.p1_level, options.p1_delay
      players[boardMaster.const.TURN.WHITE] = createPlayer options.p2, options.p2_name, options.p2_level, options.p2_delay

      gameMasterDelegate =
        endGame: ->
          console.log "end"
        stop: ->
          console.log "stop"
      gameMaster = null
      gameMaster = GameMaster gameMasterDelegate, -> players[boardMaster.current.turn()]
      gameMaster.start()


      $scope.play = ->
        $location.search("p2_level", $scope.p2_level)
        $route.reload()

      $scope.clickCell = (i, j) ->
        gameMaster.current().choice? [i, j]
  ]
