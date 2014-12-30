"use strict"

do (modulePrefix = "amo.minmax") ->
  angular.module "#{modulePrefix}.controllers", [
    "ng"
    "#{modulePrefix}.BoardMaster"
    "#{modulePrefix}.Player"
    "#{modulePrefix}.GameMaster"
    "#{modulePrefix}.module.Translator"
]
  .controller "#{modulePrefix}.controllers.minmax", [
    "$scope"
    "#{modulePrefix}.BoardMaster.RandomScoreCreator"
    "#{modulePrefix}.BoardMaster.Board"
    "#{modulePrefix}.BoardMaster.BoardMaster"
    "#{modulePrefix}.Player.Man"
    "#{modulePrefix}.Player.Com"
    "#{modulePrefix}.GameMaster.GameMaster"
    "#{modulePrefix}.module.Translator.loader.trans"
    ($scope, RandomScoreCreator, Board, BoardMaster, Man, Com, GameMaster, transLoader) ->
      $scope.min = -10
      $scope.max = 10
      $scope.rank = 7
      $scope.player = { "MAN", "COM" }
      $scope.first = $scope.player.MAN
      $scope.second = $scope.player.COM

      man = null
      com = null
      gameMaster = null
      gameMasterDelegate =
        endGame: ->
          console.log "end"
        stop: ->
          console.log "stop"

      createPlayer = (player) ->
        return Com $scope.boardMaster, 5, 1000 if player is $scope.player.COM
        return Man $scope.boardMaster
      $scope.createBoardMaster = ->
        min = $scope.min
        max = $scope.max
        rank = $scope.rank
        createScore = RandomScoreCreator min, max
        board = Board rank, createScore, "outside"
        $scope.boardMaster = BoardMaster board
        $scope.rankList = [0 .. rank - 1]

        p1 = createPlayer $scope.first
        p1.id = -> "player1"
        p2 = createPlayer $scope.second
        p2.id = -> "player2"
        gameMaster?.stop()
        gameMaster = GameMaster gameMasterDelegate, [p1, p2]
        gameMaster.start()

      $scope.clickCell = (i, j) ->
        gameMaster.current().choice? [i, j]

      $scope.transConfig =
        selectedRule: transLoader.defaultRule
        rules: transLoader.rules
        onChange: ->
          transLoader.load $scope.transConfig.selectedRule
  ]
