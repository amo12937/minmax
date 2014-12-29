"use strict"

do (modulePrefix = "amo.minmax") ->
  angular.module "#{modulePrefix}.Main", [
    "ng"
    "#{modulePrefix}.BoardMaster"
    "#{modulePrefix}.Player"
    "#{modulePrefix}.controllers"
  ]

