####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(artist, song, language, onSuccess)
#
####################################################################

class TestTranslationDataProvider
  getSegments: (artist, song, language, onSuccess) ->
    originalLyrics = []
    translatedLyrics = []
    for i in [0..300]
      ts = (i-1) * 1000
      originalLyrics.push(
        ts: ts
        text: "Lyriques quelles sont en Francais ou autre langue et sont tres bien oui? " + i
      )
      translatedLyrics.push(
        ts: ts
        text: "Test Lyrics in English that are the translation of the other that are a great translation right? " + i
      )
      
    fn = () ->
      onSuccess(
        originalLyrics: originalLyrics
        translatedLyrics: translatedLyrics
      )
    setTimeout(fn, 100)
    
window.TestTranslationDataProvider = TestTranslationDataProvider