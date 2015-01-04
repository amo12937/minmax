"use strict"

do (modulePrefix = "amo.minmax") ->
  angular.module "#{modulePrefix}.Main", [
    "ng"
    "ngLoadScript"
    "#{modulePrefix}.controllers"
  ]

