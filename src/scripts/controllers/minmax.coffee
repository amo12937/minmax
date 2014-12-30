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
    "$scope"
    "#{modulePrefix}.BoardMaster.RandomScoreCreator"
    "#{modulePrefix}.BoardMaster.Board"
    "#{modulePrefix}.BoardMaster.BoardMaster"
    "#{modulePrefix}.Player.Man"
    "#{modulePrefix}.Player.Com"
    "#{modulePrefix}.GameMaster.GameMaster"
    ($scope, RandomScoreCreator, Board, BoardMaster, Man, Com, GameMaster) ->
      $scope.configOpening = true
      $scope.min = -10
      $scope.max = 10
      $scope.rank = 7
      $scope.player = { "MAN", "COM" }
      $scope.first =
        type: $scope.player.MAN
        name: null
        namePlaceHolder: -> "#{$scope.first.type} 1"
      $scope.second =
        type: $scope.player.COM
        name: null
        namePlaceHolder: -> "#{$scope.second.type} 2"

      man = null
      com = null
      gameMaster = null
      gameMasterDelegate =
        endGame: ->
          console.log "end"
        stop: ->
          console.log "stop"

      createPlayer = (player) ->
        return Com player.name, $scope.boardMaster, 5, 1000 if player.type is $scope.player.COM
        return Man player.name, $scope.boardMaster
      $scope.createBoardMaster = ->
        $scope.configOpening = false
        min = $scope.min
        max = $scope.max
        rank = $scope.rank
        createScore = RandomScoreCreator min, max
        board = Board rank, createScore, "outside"
        $scope.boardMaster = BoardMaster board
        $scope.rankList = [0 .. rank - 1]

        $scope.first.name ?= $scope.first.namePlaceHolder()
        p1 = createPlayer $scope.first

        $scope.second.name ?= $scope.second.namePlaceHolder()
        p2 = createPlayer $scope.second
        gameMaster?.stop()
        gameMaster = GameMaster gameMasterDelegate, [p1, p2]
        gameMaster.start()

      $scope.clickCell = (i, j) ->
        gameMaster.current().choice? [i, j]
      $scope.createBoardMaster()
  ]
