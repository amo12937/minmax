"use strict"

do (moduleName = "amo.minmax.module.Translator") ->
  translatorModuleName = "amo.module.Translator"
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
        lang = query.lang or "jp"
        translator = tc.getTranslator translatorName
        translator.setRules {}
        return GetRuleApi().request("#{lang}/#{translatorName}")
          .then (response) ->
            translator.setRules response.data
            return
    ]

