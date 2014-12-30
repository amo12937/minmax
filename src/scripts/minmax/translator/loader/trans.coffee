"use strict"

do (moduleName = "amo.minmax.module.Translator") ->
  translatorModuleName = "amo.module.Translator"
  translatorName = "trans"

  angular.module moduleName
  .run ["$rootScope", "#{translatorModuleName}.translatorCollection", ($rootScope, tc) ->
    $rootScope.trans = tc.getTranslator translatorName
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
        load: (rulesKey) ->
          translator.setRules {}
          GetRuleApi().request "#{rulesKey}/#{translatorName}"
          .then (response) ->
            translator.setRules response.data
      self.load self.defaultRule
      return self
  ]
