class YablaDictionaryDataProvider

  lookup: (word, fromLanguage, toLanguage, callback) ->
    success = (result) =>
      dictionaryMarkup = eval('(' + result + ')').text
      callback(dictionaryMarkup)

    $.ajax(
      type: 'GET'
      url: 'http://yabla.com/player_service.php'
      data:
        action: 'lookup'
        word: word
        word_lang_id: fromLanguage
        output_lang_id: toLanguage
      success: success
    )
    
window.YablaDictionaryDataProvider = YablaDictionaryDataProvider