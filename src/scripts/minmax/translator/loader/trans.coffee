"use strict"

do (moduleName = "amo.minmax.module.Translator") ->
  translatorModuleName = "amo.module.Translator"
  translatorName = "trans"

  angular.module moduleName
  .config ["#{translatorModuleName}.translatorCollectionProvider", (tcProvider) ->
    tcProvider.registerTranslator translatorName
  ]
  .factory "#{moduleName}.loader.trans", [
    "#{translatorModuleName}.translatorCollection"
    "#{moduleName}.api.GetRule"
    "#{moduleName}.config"
    (tc, GetRuleApi, config) ->
      translator = tc.getTranslator translatorName
      self =
        rules: config.loader.trans.rules
        defaultRule: config.loader.trans.defaultRule
        trans: {}
        load: (rulesKey) ->
          translator.setRules {}
          self.trans = {}
          GetRuleApi().request "#{rulesKey}/#{translatorName}"
          .then (response) ->
            console.log response.data
            self.trans = response.data
            translator.setRules response.data
      self.load self.defaultRule
      return self
  ]
