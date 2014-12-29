"use strict"

do (modulePrefix = "amo.minmax") ->
  angular.module "#{modulePrefix}.controllers", ["ng", "#{modulePrefix}.BoardMaster", "#{modulePrefix}.Player", "#{modulePrefix}.GameMaster"]
  .controller "#{modulePrefix}.controllers.minmax", [
    "$scope"
    "#{modulePrefix}.BoardMaster.RandomScoreCreator"
    "#{modulePrefix}.BoardMaster.Board"
    "#{modulePrefix}.BoardMaster.BoardMaster"
    "#{modulePrefix}.Player.Man"
    "#{modulePrefix}.Player.Minmax"
    "#{modulePrefix}.GameMaster.GameMaster"
    ($scope, RandomScoreCreator, Board, BoardMaster, Man, Com, GameMaster) ->
      $scope.min = -10
      $scope.max = 10
      $scope.rank = 7
      $scope.turn = BoardMaster.TURN.H
      $scope.turnValue =
        MAN: BoardMaster.TURN.H
        COM: BoardMaster.TURN.V

      man = null
      com = null
      gameMaster = GameMaster
        end: ->
          console.log "end"
        stop: ->
          console.log "stop"

      $scope.createBoardMaster = ->
        min = $scope.min
        max = $scope.max
        rank = $scope.rank
        turn = Number $scope.turn
        createScore = RandomScoreCreator min, max
        board = Board rank, createScore, "outside"
        $scope.boardMaster = BoardMaster board, turn
        $scope.rankList = [0 .. rank - 1]
        man = Man $scope.boardMaster
        com = Com $scope.boardMaster
        if turn is BoardMaster.TURN.H
          gameMaster.start man, com
        else
          gameMaster.start com, man

      $scope.clickCell = (i, j) ->
        man.choice [i, j]
  ]
