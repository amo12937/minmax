"use strict"

do (moduleName = "amo.minmax.module.translator") ->
  translatorModuleName = "amo.module.translator"
  translatorName = "trans"

  angular.module moduleName
  .config ["#{translatorModuleName}.translatorCollectionProvider", (tcProvider) ->
    tcProvider.registerTranslator translatorName
  ]
  .provider "#{moduleName}.transResolver", ->
    $get: -> {}
    getResolver: -> [
      "$location"
      "#{translatorModuleName}.translatorCollection"
      "#{moduleName}.api.GetRule"
      ($location, tc, GetRuleApi) ->
        query = $location.search()
        lang = query.lang or "ja"
        translator = tc.getTranslator translatorName
        translator.setRule {}
        return GetRuleApi().request("#{lang}/#{translatorName}")
          .then (response) ->
            translator.setRule response.data
            return
    ]

