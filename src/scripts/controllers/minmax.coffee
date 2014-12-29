"use strict"

do (modulePrefix = "amo.minmax") ->
  angular.module "#{modulePrefix}.controllers", ["ng", "#{modulePrefix}.BoardMaster"]
  .controller "#{modulePrefix}.controllers.minmax", [
    "$scope"
    "#{modulePrefix}.BoardMaster.RandomScoreCreator"
    "#{modulePrefix}.BoardMaster.Board"
    "#{modulePrefix}.BoardMaster.BoardMaster"
    ($scope, RandomScoreCreator, Board, BoardMaster) ->
      $scope.min = -10
      $scope.max = 10
      $scope.rank = 7

      $scope.createBoardMaster = ->
        console.log "hoge"
        min = $scope.min
        max = $scope.max
        rank = $scope.rank
        createScore = RandomScoreCreator min, max
        board = Board rank, createScore, "outside"
        $scope.boardMaster = BoardMaster board
        $scope.rankList = [0 .. rank - 1]

      $scope.clickCell = (i, j) ->
        $scope.boardMaster.select [i, j]
  ]
