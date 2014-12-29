"use strict"

angular.element(window.document).ready ->
  try
    angular.bootstrap window.document, ["amo.minmax.Main"]
  catch e
    p = e.message.indexOf "?"
    console.log decodeURIComponent e.message[p + 1 ..]
    console.log e

