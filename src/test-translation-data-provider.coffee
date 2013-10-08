define () ->
  ####################################################################
  #Interface:
  #
  # TranslationDataProvider = () ->
  #   getSegments(artist, song, language, onSuccess)
  #
  ####################################################################

  class TestTranslationDataProvider
    getSegments: (artist, song, language, onSuccess) ->
      originalSubtitles = []
      translatedSubtitles = []
      for i in [0..300]
        ts = (i-1) * 1000
        originalSubtitles.push(
          ts: ts
          text: "Lyriques quelles sont en Francais ou autre langue et sont tres bien oui? " + i
        )
        translatedSubtitles.push(
          ts: ts
          text: "Test Subtitles in English that are the translation of the other that are a great translation right? " + i
        )
        
      fn = () ->
        onSuccess(
          originalSubtitles: originalSubtitles
          translatedSubtitles: translatedSubtitles
        )
      setTimeout(fn, 100)
      
  return TestTranslationDataProvider